//
//  MockURLProtocol.swift
//  Aura
//
//  Created by Renaud Leroy on 01/07/2025.
//


import XCTest

final class MockURLProtocol: URLProtocol {
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	static var requestHandler: ((URLRequest) throws -> (URLResponse?, Data?, Error?))?
	
	override func startLoading() {
		guard let handler = MockURLProtocol.requestHandler else {
			XCTFail("No handler provided for MockURLProtocol")
			return
		}
		
		do {
			let (response, data, error) = try handler(request)
			
			if let error = error {
				client?.urlProtocol(self, didFailWithError: error)
				return
			}
			
			guard let unwrappedResponse = response else {
				return
			}

			client?.urlProtocol(self, didReceive: unwrappedResponse, cacheStoragePolicy: .notAllowed)
			
			if let data = data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			XCTFail("Error handling the request: \(error)")
		}
	}
	
	override func stopLoading() {
	}
}