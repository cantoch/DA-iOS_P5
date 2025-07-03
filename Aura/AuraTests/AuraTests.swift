//
//  AuraTests.swift
//  AuraTests
//
//  Created by Renaud Leroy on 01/07/2025.
//

import XCTest
@testable import Aura

final class AuraAPIServiceTests: XCTestCase {
    let mockSession = AuraAPIServiceMock()
    var session = URLSession(configuration: .ephemeral)
    var apiService: AuraAPIService!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        apiService = AuraAPIService(session: session)
    }
    
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.requestHandler = nil
        apiService = nil
    }
    
    func testCreateEndpoint() throws {
        do {
            let url = try apiService.createEndpoint(path: .login)
            XCTAssertEqual("http://127.0.0.1:8080/auth",url.absoluteString)
        }
        catch {
            XCTFail("Error \(error)")
        }
    }
    
    func testCreateEndpointErrorOccurs() throws {
        apiService = AuraAPIService(session: session, baseURLString: "")
        do {
            _ = try apiService.createEndpoint(path: .login)
            XCTFail( "Error should occur")
        }
        catch {
            XCTAssertEqual(error as? APIError, APIError.invalidURL)
        }
    }
    
    func testSerializeParametersSuccess() throws {
        let parameters: [String: Any] = ["key": "value"]
        let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let result = try apiService.serializeParameters(parameters: parameters)
        XCTAssertEqual(data, result)
    }
}
