//
//  MockAPIService.swift
//  Aura
//
//  Created by Renaud Leroy on 20/07/2025.
//
import Foundation
@testable import Aura

final class MockAPIService: AuraAPIServiceProtocol {

    var scenario: MockScenario
    
    enum MockScenario {
        case success
        case decodingError
        case noToken
        case httpError
        case noData
    }
    
    init (scenario: MockScenario = .success) {
        self.scenario = scenario
    }
    
    func createEndpoint(path: AuraAPIService.Path) throws -> URL {
        return URL(string: "http://127.0.0.1:8080/auth")!
    }
    
    func createRequest(jsonData: Data?, endpoint: URL, method: AuraAPIService.Method) -> URLRequest {
        return URLRequest(url: endpoint)
    }
    
    func fetchAndDecode<T>(_ type: T.Type, request: URLRequest, allowEmptyData: Bool) async throws -> T? where T : Decodable {
        switch scenario {
        case .success:
            if type == AuthResponse.self {
                let mockResponse = AuthResponse(token: "mock_token")
                return mockResponse as? T
            } else if type == AccountDetail.self {
                let mockResponse = AccountDetail(
                    transactions: [
                        Transaction(label: "Payment1", value: 150.0),
                        Transaction(label: "Payment2", value: 500.0)
                    ],
                    currentBalance: 650.0
                )
                return mockResponse as? T
            }
        case .decodingError:
            throw APIError.decodingError
        case .noToken:
            return nil
        case .httpError:
            throw APIError.httpError(statusCode: 500)
        case .noData:
            return nil
        }
        return nil
    }

    func fetch(request: URLRequest, allowEmptyData: Bool) async throws -> Data {
        switch scenario {
        case .success:
            return Data()
        case .decodingError:
            throw APIError.decodingError
        case .noToken:
            throw APIError.unauthorized
        case .httpError:
            throw APIError.httpError(statusCode: 500)
        case .noData:
            if !allowEmptyData {
                throw APIError.noData
            }
            return Data()
        }
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


