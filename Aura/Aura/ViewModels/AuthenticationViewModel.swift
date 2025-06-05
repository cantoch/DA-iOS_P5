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
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8080/auth")!)
        request.httpMethod = "POST"
        
        let body = LoginRequest(username: username, password: password)
        
        let jsonData = try! JSONEncoder().encode(body)
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")  // Cela indique a l'API que le corps contient du JSON
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("mauvais statutcode")
                    return
                }
                
                do {
                    let tokenResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                } catch {
                }
            }
        }
        .resume()
    }
}
