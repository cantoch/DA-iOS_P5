//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

protocol AuraAPIServiceProtocol {
    func createEndpoint(path: AuraAPIService.Path) throws -> URL
    func createRequest(parameters: [String: Any]?, jsonData: Data?, endpoint: URL, method: AuraAPIService.Method) -> URLRequest
    func fetchAndDecode<T: Decodable>(_ type: T.Type, request: URLRequest, allowEmptyData: Bool) async throws -> T?
}

protocol AuraKeychainServiceProtocol {
    func saveToken(token: String, key: String) throws -> Bool
    func deleteToken(key: String) throws -> Bool
    func getToken(key: String) throws -> String?
}

extension AuraAPIService: AuraAPIServiceProtocol {}

extension AuraKeychainService: AuraKeychainServiceProtocol {}

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    private let apiService: AuraAPIServiceProtocol
    private let keychainService: AuraKeychainServiceProtocol
    
    private let onLoginSucceed: (() -> ())
    
    init(apiService: AuraAPIServiceProtocol = AuraAPIService(), keychainService: AuraKeychainServiceProtocol = AuraKeychainService(), onLoginSucceed: @escaping () -> Void) {
        self.apiService = apiService
        self.keychainService = keychainService
        self.onLoginSucceed = onLoginSucceed
    }
    
    @MainActor
    func login() async {
        let body = AuthRequest(username: username, password: password)
        
        guard username.contains("@"), !password.isEmpty else {
            return
        }
        let parameters: [String: Any] = ["username": username, "password": password]
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            guard let path = try? apiService.createEndpoint(path: .login) else {
                return
            }
            let request = apiService.createRequest(parameters: parameters, jsonData: jsonData, endpoint: path, method: .post)
            
            guard let response = try await apiService.fetchAndDecode(AuthResponse.self, request: request, allowEmptyData: false) else {
                return
            }
            let token = response.token
            _ = try keychainService.deleteToken(key: "auth_token")
            _ = try keychainService.saveToken(token: token, key: "auth_token")
            
            self.onLoginSucceed()
        } catch {
            print("Erreur lors du login")
        }
    }
}




