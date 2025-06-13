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
    
    func login() {
        let auraApiService = AuraAPIService()
        let body = LoginRequest(username: username, password: password)
        let method: AuraAPIService.Method = .post
        let auraKeychainService = AuraKeychainService()
        
        guard username.contains("@") else {
            print("adresse mail non valide")
            return
        }
        
        Task {
            let jsonData = try! JSONEncoder().encode(body)
            let path = try! AuraAPIService().createEndpoint(path: .login)
            let request = AuraAPIService().createRequest(jsonData: jsonData, endpoint: path, method: method)
            
            let response = try await auraApiService.fetchAndDecode(LoginResponse.self, request: request)
            let token
            try! auraKeychainService.saveToken(token, key: "\(username)Token")
            
        }
        self.onLoginSucceed()
    }
}




