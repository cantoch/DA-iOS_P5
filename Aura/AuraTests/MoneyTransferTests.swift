//
//  MoneyTransfertTests.swift
//  Aura
//
//  Created by Renaud Leroy on 23/07/2025.
//

import XCTest
@testable import Aura
 
final class MoneyTransferTests: XCTestCase {
    func testMoneyTransferSuccess() async {
        let apiService = MockAPIService()
        let keychainService = MockKeychainService()
        keychainService.saved["auth_token"] = "mock_token"
        
        let viewModel = MoneyTransferViewModel(
            keychainService: keychainService,
            apiService: apiService
        )
        viewModel.amount = "100"
        viewModel.recipient = "bibi"
        
        await viewModel.sendMoney()
     
        XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100€ to bibi")
    }
}
