//
//  MockScenarioAPIService.swift
//  Aura
//
//  Created by Renaud Leroy on 01/07/2025.
//


import XCTest
@testable import Aura

enum MockScenarioAPIService {
	case successWithoutBody
	case successWithBody
	case serverError
	case statusCodeError
	case networkError
    case emptyData
}

struct AuraAPIServiceMock {
	func makeMock(for scenario: MockScenarioAPIService) -> (URLResponse?, Data?, Error?) {
		switch scenario {
		case .successWithoutBody:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let jsonData = """
				 {
				  "currentBalance": 100.0,
				  "transactions": []
				 }
				 """.data(using: .utf8)!
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .successWithBody:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account/transfer")!,
										   statusCode: 200,
										   httpVersion: nil,
										   headerFields: nil)!
			let data = Data()
			
			MockURLProtocol.requestHandler = { request in
				return (response, data, nil) // Réponse simulée
			}
			
			return (response, data, nil)
			
			
		case .serverError:
			let response = URLResponse(url: URL(string: "http://127.0.0.1:8080/account")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
			let jsonData = """
				 {
				  "currentBalance": 100.0,
				  "transactions": []
				 }
				 """.data(using: .utf8)!
			
			MockURLProtocol.requestHandler = { request in
				return (response, jsonData, nil) // Réponse simulée
			}
			
			return (response, jsonData, nil)
			
		case .statusCodeError:
			let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
										   statusCode: 500,
										   httpVersion: nil,
										   headerFields: nil)!
			let data = """
				{
				 "currentBalance": 100.0,
				 "transactions": []
				}
				""".data(using: .utf8)!
			MockURLProtocol.requestHandler = { request in
				return (response, data, nil)
			}
			
			return (response, data, nil)
			
			
		case .networkError:
            let error = URLError(.notConnectedToInternet)
			MockURLProtocol.requestHandler = { request in
				return (nil, nil, error) // Réponse simulée
			}
			return (nil, nil, error)
            
            
        case .emptyData:
            let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/account")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            MockURLProtocol.requestHandler = { request in
                return (response, Data(), nil)
            }
            return (response, Data(), nil)
		}
	}
}
