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
    var viewModel: AllTransactionsViewModel!
    var apiService: MockAPIService!
    var keychainService: MockKeychainService!
    
    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        keychainService = MockKeychainService()
        keychainService.saved["auth_token"] = "mock_token"
        viewModel = AllTransactionsViewModel(
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
    
    func testAllTransactionsSuccess() async {        
        let mockTransactions = [
            Transaction(label: "Payment1", value: 150.0),
            Transaction(label: "Payment2", value: 500.0)
        ]
        let mockBalance: Double = 650.0
        
        await viewModel.allTransactions()
        
        XCTAssertEqual(viewModel.transactions, mockTransactions)
        XCTAssertEqual(viewModel.currentBalance, mockBalance)
    }
 
    func testAllTransactionsFailsWhenNoToken() async {
        apiService.scenario = .noToken
        
        await viewModel.allTransactions()
        
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertEqual(viewModel.currentBalance, 0.0)
    }
    
    func testAllTransactionsFailsOnAPIDecodingError() async {
        apiService.scenario = .decodingError
        
        await viewModel.allTransactions()
        
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertEqual(viewModel.currentBalance, 0.0)
    }
    
    func testAllTransactionsFailsWhenAPIReturnsNil() async {
        apiService.scenario = .noData
        
        await viewModel.allTransactions()
        
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertEqual(viewModel.currentBalance, 0.0)
    }
}

