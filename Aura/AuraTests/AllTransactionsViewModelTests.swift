//
//  AlltransactionsViewModelTests.swift
//  Aura
//
//  Created by Renaud Leroy on 22/07/2025.
//
//
import XCTest
@testable import Aura

class AllTransactionsViewModelTests: XCTestCase {
    
    func testAllTransactionsSuccess() async {
        let keychainService = MockKeychainService()
        let apiService = MockAPIService()
        keychainService.saved["auth_token"] = "mock_token"
        
        let viewModel = AllTransactionsViewModel(
            keychainService: keychainService,
            apiService: apiService
        )
        
        let mockTransactions = [
            Transaction(label: "Payment1", value: 150.0),
            Transaction(label: "Payment2", value: 500.0)
        ]
        let mockBalance: Double = 650.0
        await viewModel.allTransactions()
        
        XCTAssertEqual(viewModel.transactions, mockTransactions)
        XCTAssertEqual(viewModel.currentBalance, mockBalance)
    }
}

