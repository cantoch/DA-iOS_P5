//
//  Model.swift
//  Aura
//
//  Created by Renaud Leroy on 03/06/2025.
//

import Foundation

struct AuthRequest: Encodable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
}

