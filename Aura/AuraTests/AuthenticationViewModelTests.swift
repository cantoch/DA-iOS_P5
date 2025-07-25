//
//  AuthenticationViewModelTests.swift
//  Aura
//
//  Created by Renaud Leroy on 20/07/2025.
//
import XCTest
@testable import Aura

final class AuthenticationViewModelTests: XCTestCase {
    
    var viewModel: AuthenticationViewModel!
    var mockAPIService: MockAPIService!
    var mockKeychainService: MockKeychainService!
    var loginDidSucceed: Bool!
    
    override func setUp() {
        super.setUp()
        loginDidSucceed = false
        mockAPIService = MockAPIService()
        mockKeychainService = MockKeychainService()
        viewModel = AuthenticationViewModel(
            apiService: mockAPIService,
            keychainService: mockKeychainService,
            onLoginSucceed: { [weak self] in self?.loginDidSucceed = true }
        )
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        mockAPIService = nil
        mockKeychainService = nil
        loginDidSucceed = false
    }
    
    func testLoginSuccessCallsCallbackAndStoresToken() async {
        viewModel.username = "user@example.com"
        viewModel.password = "securepassword"
        await viewModel.login()
        XCTAssertTrue(loginDidSucceed)
        XCTAssertEqual(mockKeychainService.saved["auth_token"], "mock_token")
    }
    
    func testLoginFailedWithInvalidEmail() async {
        viewModel.username = "toto"
        viewModel.password = "securepassword"
        await viewModel.login()
        XCTAssertFalse(loginDidSucceed)
        XCTAssertTrue(mockKeychainService.saved.isEmpty)
    }
    
    func testLoginFailedWhenApiReturnNil() async {
        mockAPIService.scenario = .noToken
        viewModel.username = "user@example.com"
        viewModel.password = "securepassword"
        await viewModel.login()
        XCTAssertFalse(loginDidSucceed)
        XCTAssertTrue(mockKeychainService.saved.isEmpty)
    }
    
    func testLoginFailedWhenDecodingError() async {
        mockAPIService.scenario = .decodingError
        viewModel.username = "user@example.com"
        viewModel.password = "securepassword"
        await viewModel.login()
        XCTAssertFalse(loginDidSucceed)
        XCTAssertTrue(mockKeychainService.saved.isEmpty)
    }
}
