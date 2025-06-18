//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    let onLoginSucceed: (() -> ())   // ?????
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    @MainActor
    func login() async {
        let auraApiService = AuraAPIService()
        let body = AuthRequest(username: username, password: password)
        let auraKeychainService = AuraKeychainService()
        
        guard username.contains("@") else {
            return
        }
        let parameters: [String: Any] = ["username": username, "password": password]
        
        Task {
            do {
                let jsonData = try JSONEncoder().encode(body)
                let path = try! AuraAPIService().createEndpoint(path: .login)
                let request = AuraAPIService().createRequest(parameters: parameters, jsonData: jsonData, endpoint: path, method: .post)

                guard let response = try await auraApiService.fetchAndDecode(LoginResponse.self, request: request) else {
                    return
                }
                
                let token = response.token
                try auraKeychainService.deleteToken(key: "auth_token")
                try auraKeychainService.saveToken(token: token, key: "auth_token")
                
                self.onLoginSucceed()
            } catch {
            }
        }
    }
}




