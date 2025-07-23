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

struct AuthResponseMock: Decodable {
    let currentBalance: Double
    let transactions: [Transaction]
}

struct AccountDetail : Decodable {
    let transactions: [Transaction]
    let currentBalance: Double
}

struct Transaction: Decodable, Equatable {
    let label: String
    let value: Double
}

struct TransferRequest: Encodable {
    let recipient : String
    let amount : Decimal
}

struct EmptyResponse: Decodable {}
