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
            XCTFail("Error \(APIError.invalidURL)")
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
        do {
            let data = try apiService.serializeParameters(parameters: parameters)
            XCTAssertNotNil(data)
        }
        catch {
            XCTFail("Error \(error)")
        }
    }
    
    func testSerializeParametersErrorOccurs() throws {
        let parameters: [String: Any] = ["date":Date()]
        do {
            let data = try apiService.serializeParameters(parameters: parameters)
            XCTAssertNil(data)
        }
        catch {
            XCTAssertEqual(error as? APIError, APIError.invalidParameters)
        }
    }
    
    func testCreateRequestSuccessWithoutBody() throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        let data: Data? = nil
        let method: AuraAPIService.Method = .get
        let request = apiService.createRequest(jsonData: data, endpoint: url, method: method)
        XCTAssertEqual(request.httpMethod, method.rawValue)
        XCTAssertEqual(request.url, url)
        XCTAssertNil(request.httpBody)
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
    }
    
    func testCreateRequestWithBody() throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        let method: AuraAPIService.Method = .get
        let body: [String: Any] = [
            "toto": "0123456789",
            "amount": 15
        ]
        let data: Data? = try JSONSerialization.data(withJSONObject: body, options: [])
        let request = apiService.createRequest(parameters: body, jsonData: data, endpoint: url, method: method)
        XCTAssertEqual(request.httpMethod, method.rawValue)
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.httpBody, data)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testFetchWithoutBodySuccess() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        let (_, expectedData, _) = mockSession.makeMock(for: .successWithoutBody)
        let allowEmptyData: Bool = true
        
        do {
            let data = try await apiService.fetch(request: request, allowEmptyData: allowEmptyData)
            XCTAssertEqual(data, expectedData)
        }
        catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testFetchWithBodySuccess() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let body: [String: Any] = [
            "toto": "0123456789",
            "amount": 15
        ]
        let data: Data? = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, expectedData, _) = mockSession.makeMock(for: .successWithBody)
        let allowEmptyData: Bool = true
        
        do {
            let data = try await apiService.fetch(request: request, allowEmptyData: allowEmptyData)
            XCTAssertEqual(data, expectedData)
        }
        catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testFetchInvalidResponseOccurs() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let (_, _, _) = mockSession.makeMock(for: .serverError)
        
        do {
            _ = try await apiService.fetch(request: request)
            XCTFail("should throw an error")
        }
        catch APIError.invalidResponse {
            XCTAssertTrue(true, "invalid response correctly caught")
        }
        catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testFetchStatusCodeErrorOccurs() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let (_, _, _) = mockSession.makeMock(for: .statusCodeError)
        
        do {
            _ = try await apiService.fetch(request: request)
            XCTFail(".statusCodeError should throw an error")
        }
        catch APIError.httpError(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        }
        catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testFetchNetworkErrorOccurs() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let (_, _, _) = mockSession.makeMock(for: .networkError)
        
        do {
            _ = try await apiService.fetch(request: request)
            XCTFail(".networkError should throw an error")
        }
        catch APIError.networkError {
            XCTAssert(true)
        }
    }
    
    func testFetchEmptyData() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let (_, _, _) = mockSession.makeMock(for: .emptyData)
        
        do {
            _ = try await apiService.fetch(request: request)
            XCTFail(".emptyData should throw an error")
        }
        catch APIError.noData {
            XCTAssert(true)
        }
    }
    
    func testFetchAndDecodeWithoutBodySuccess() async throws {
        let url = URL(string: "http://127.0.0.1:8080/auth")!
        var request = URLRequest(url: url)
        let method: AuraAPIService.Method = .get
        request.httpMethod = method.rawValue
        
        let (_, _, _) = mockSession.makeMock(for: .successWithoutBody)
        
        do {
            let decodedResponse = try await apiService.fetchAndDecode(AuthResponseMock.self, request: request)
            XCTAssertEqual(decodedResponse?.currentBalance, 100.0)
            XCTAssertEqual(decodedResponse?.transactions.count, 0)
        }
        catch {
            XCTFail("Should not throw an error")
            print("Error: \(error)")
        }
    }
}

