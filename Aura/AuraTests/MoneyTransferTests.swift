//
//  MoneyTransfertTests.swift
//  Aura
//
//  Created by Renaud Leroy on 23/07/2025.
//

import XCTest
@testable import Aura

final class MoneyTransferTests: XCTestCase {
    var apiService: MockAPIService!
    var keychainService: MockKeychainService!
    var viewModel: MoneyTransferViewModel!
    
    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        keychainService = MockKeychainService()
        keychainService.saved["auth_token"] = "mock_token"
        viewModel = MoneyTransferViewModel(
            keychainService: keychainService,
            apiService: apiService
        )
    }
    
    override func tearDown() {
        apiService = nil
        keychainService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testMoneyTransferSuccess() async {
        viewModel.amount = "100"
        viewModel.recipient = "bibi"
        
        await viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100€ to bibi")
    }
    
    func testMoneyTransferFailsWithInvalidAmountFormat() async {
        viewModel.amount = "toto"
        viewModel.recipient = "bibi"
        
        await viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.errorMessage, "Erreur de format")
    }
    
    func testMoneyTransferFailsWithoutToken() async {
        keychainService.saved["auth_token"] = nil
        viewModel.amount = "100"
        viewModel.recipient = "bibi"
        
        await viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.errorMessage, "Echec d'identification")
    }
    func testMoneyTransferFailsOnAPIError() async {
        apiService.scenario = .httpError
        viewModel.amount = "100"
        viewModel.recipient = "bibi"
        
        await viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.errorMessage, "Erreur lors du transfert")
    }
}
