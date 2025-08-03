//
//  AccountDetailViewModelTests.swift
//  Aura
//
//  Created by Renaud Leroy on 21/07/2025.
//

import XCTest
@testable import Aura

final class AccountViewModelTests: XCTestCase {
    var viewModel: AccountViewModel!
    var apiService: MockAPIService!
    var keychainService: MockKeychainService!
    
    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        keychainService = MockKeychainService()
        keychainService.saved["auth_token"] = "mock_token" 
        viewModel = AccountViewModel(
            keychainService: keychainService,
            apiService: apiService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        apiService = nil
        keychainService = nil
        super.tearDown()
    }
    
    func testAccountSuccess() async {
        let mockTransactions = [
            Transaction(label: "Payment1", value: 150.0),
            Transaction(label: "Payment2", value: 500.0)
        ]
        let mockBalance: Double = 650.0
        await viewModel.account()
        
        XCTAssertEqual(viewModel.transactions, mockTransactions)
        XCTAssertEqual(viewModel.currentBalance, mockBalance)
    }
    
    func testAccountFailsOnAPIDecodingError() async {
        apiService.scenario = .decodingError
        
        await viewModel.account()
        
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertEqual(viewModel.currentBalance, 0.0)
    }
}
