//
//  Model.swift
//  Aura
//
//  Created by Renaud Leroy on 03/06/2025.
//

struct AuthRequest: Encodable { // à renommer
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}
