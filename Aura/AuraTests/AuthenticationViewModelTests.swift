//
//  AuthenticationViewModelTests.swift
//  Aura
//
//  Created by Renaud Leroy on 20/07/2025.
//
import XCTest
@testable import Aura

final class AuthenticationViewModelTests: XCTestCase {
    
    func testLoginSuccessCallsCallbackAndStoresToken() async {
        let apiService = MockAPIService()
        let keychainService = MockKeychainService()
        var loginSuccess = false
        
        let viewModel = AuthenticationViewModel(
            apiService: apiService,
            keychainService: keychainService
        ) {
            loginSuccess = true
        }
        viewModel.username = "user@example.com"
        viewModel.password = "securepassword"
        await viewModel.login()
        XCTAssertTrue(loginSuccess)
        XCTAssertEqual(keychainService.saved["auth_token"], "mock_token")
    }
}
