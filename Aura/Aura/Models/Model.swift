//
//  Model.swift
//  Aura
//
//  Created by Renaud Leroy on 03/06/2025.
//

struct AuthenticationRequest: Encodable { // à renommer
    let username: String
    let password: String
}

struct AuthenticationResponse: Codable {
    let token: String
}
