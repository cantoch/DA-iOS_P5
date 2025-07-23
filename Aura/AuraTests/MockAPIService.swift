//
//  MockAPIService.swift
//  Aura
//
//  Created by Renaud Leroy on 20/07/2025.
//
import Foundation
@testable import Aura

final class MockAPIService: AuraAPIServiceProtocol {
    var shouldReturnError = false
    var mockToken = "mock_token"
    var mockResponse: Any?
    
    func createEndpoint(path: AuraAPIService.Path) throws -> URL {
        return URL(string: "http://127.0.0.1:8080/auth")!
    }
    
    func createRequest(parameters: [String : Any]?, jsonData: Data?, endpoint: URL, method: AuraAPIService.Method) -> URLRequest {
        return URLRequest(url: endpoint)
    }
    
    func fetchAndDecode<T>(_ type: T.Type, request: URLRequest, allowEmptyData: Bool) async throws -> T? where T : Decodable {
        if shouldReturnError {
            throw APIError.decodingError
        }
        if type == AccountDetail.self {
            let mockResponse = AccountDetail(
                transactions: [
                    Transaction(label: "Payment1", value: 150.0),
                    Transaction(label: "Payment2", value: 500.0)
                ],
                currentBalance: 650.0
            )
            return mockResponse as? T
        } else if type == AuthResponse.self {
            let mockResponse = AuthResponse(token: mockToken)
            return mockResponse as? T
        }
        return nil
    }
}

final class MockKeychainService: AuraKeychainServiceProtocol {
    var saved: [String: String] = [:]
    func saveToken(token: String, key: String) throws -> Bool {
        saved[key] = token
        return true
    }
    
    func deleteToken(key: String) throws -> Bool {
        saved.removeValue(forKey: key)
        return true
    }
    
    func getToken(key: String) throws -> String? {
        saved[key]
    }
}

