//
//  AccountDetailViewModelTests.swift
//  Aura
//
//  Created by Renaud Leroy on 21/07/2025.
//

import XCTest
@testable import Aura

final class AccountViewModelTests: XCTestCase {
    
    func testAccountSuccess() async {
        let apiService = MockAPIService()
        let keychainService = MockKeychainService()
        keychainService.saved["auth_token"] = "mock_token"
        
        let viewModel = AccountViewModel(
            keychainService: keychainService,
            apiService: apiService
        )
        
        let mockTransactions = [
            Transaction(label: "Payment1", value: 150.0),
            Transaction(label: "Payment2", value: 500.0)
        ]
        let mockBalance: Double = 650.0
        await viewModel.account()
        
        XCTAssertEqual(viewModel.transactions, mockTransactions)
        XCTAssertEqual(viewModel.currentBalance, mockBalance)
    }
}
