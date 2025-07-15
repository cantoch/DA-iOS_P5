//
//  APIError.swift
//  Aura
//
//  Created by Renaud Leroy on 09/06/2025.
//


import Foundation

enum APIError: LocalizedError, Equatable {
	case invalidURL
	case invalidParameters
	case invalidResponse
	case httpError(statusCode: Int)
	case noData
	case unauthorized
	case decodingError
    case networkError

	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "The URL is invalid."
		case .invalidParameters:
			return "Invalid parameters provided."
		case .invalidResponse:
			return "Invalid response from the server."
		case .httpError(let statusCode):
			return "HTTP error: \(statusCode)"
		case .noData:
			return "No data received from the server."
		case .unauthorized: 
			return "You are not authorized to perform this action."
		case .decodingError:
			return "Decoding error."
        case .networkError:
            return "Network error."
		}
	}
}
