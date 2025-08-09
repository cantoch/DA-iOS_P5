//
//  AuraAPIService.swift
//  Aura
//
//  Created by Renaud Leroy on 09/06/2025.
//


import Foundation

protocol AuraAPIServiceProtocol {
    func createEndpoint(path: AuraAPIService.Path) throws -> URL
    func createRequest(jsonData: Data?, endpoint: URL, method: AuraAPIService.Method) -> URLRequest
    func fetchAndDecode<T: Decodable>(_ type: T.Type, request: URLRequest, allowEmptyData: Bool) async throws -> T?
    func fetch(request: URLRequest, allowEmptyData: Bool) async throws -> Data
}

struct AuraAPIService {
    
    //MARK: -Private properties
    private let session: URLSession
    private let baseURLString : String
    
    //MARK: -Initialization
    init(session: URLSession = .shared, baseURLString: String = "http://127.0.0.1:8080") {
        self.session = session
        self.baseURLString = baseURLString
    }
    
    //MARK: -Enumerations
    enum Path: String {
        case login = "/auth"
        case fetchAccountsDetails = "/account"
        case makeTransaction = "/account/transfer"
    }
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    //MARK: -Methods
    func createEndpoint(path: Path) throws -> URL {
        guard let baseURL = URL(string: baseURLString) else {
            throw APIError.invalidURL
        }
        return baseURL.appendingPathComponent(path.rawValue)
    }
    
    //sérialisation
    func serializeParameters(parameters: [String: Any]) throws -> Data?  {
        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw APIError.invalidParameters
        }
        return try? JSONSerialization.data(withJSONObject: parameters, options: [])
    }
    
    //requête
    func createRequest(jsonData: Data?, endpoint: URL, method: Method) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue

        if let jsonData = jsonData {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        }
        return request
    }
    
    //appel réseau
    func fetch(request: URLRequest, allowEmptyData: Bool = false) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            
            if !allowEmptyData && data.isEmpty {
                throw APIError.noData
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            return data
        } catch _ as URLError {
            throw APIError.networkError
        }
    }
    
    
    
    func decode<T: Decodable>(_ type: T.Type, data: Data) throws -> T? {
        guard let responseJSON = try? JSONDecoder().decode(T.self, from: data) else {
            throw APIError.decodingError
        }
        return responseJSON
    }
    
    func fetchAndDecode<T: Decodable>(_ type: T.Type, request: URLRequest, allowEmptyData: Bool = false) async throws -> T? {
        let data = try await fetch(request: request,  allowEmptyData: allowEmptyData)
        if data.isEmpty {
            return nil
        }
        let decodedData = try decode(T.self, data: data)
        return decodedData
    }
}

