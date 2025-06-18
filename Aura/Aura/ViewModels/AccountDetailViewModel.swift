//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

//import Foundation
//
//class AccountDetailViewModel: ObservableObject {
//    @Published var totalAmount: String = "€8,345.67"
//    @Published var recentTransactions: [Transaction] = [
//        Transaction(description: "Starbucks", amount: "-€5.50"),
//        Transaction(description: "Amazon Purchase", amount: "-€32.99"),
//        Transaction(description: "Apple Store", amount: "-€28.99"),
//        Transaction(description: "Amazon Purchase", amount: "-€34.99"),
//        Transaction(description: "Amazon Purchase", amount: "-€79.99"),
//        Transaction(description: "Salary", amount: "+€2,500.00")
//    ]
//    
//    struct Transaction {
//        let description: String
//        let amount: String
//    }
//}

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var currentBalance: Double = 0.0
    @Published var transactions: [Transaction] = []
    
    struct AccountDetail : Decodable {
        let transactions: [Transaction]
        let currentBalance: Double
    }
    
    struct Transaction: Decodable {
        let UUID: String
        let label: String
        let value: String
    }
    
    @MainActor
    func account() {
        let auraKeychainService = AuraKeychainService()
        let auraApiService = AuraAPIService()
        guard let token = try? auraKeychainService.getToken(key: "auth_token") else { return
        }
        
        Task {
            do {
                let path = try! AuraAPIService().createEndpoint(path: .fetchAccountsDetails)
                var request = AuraAPIService().createRequest(parameters: nil, jsonData: nil, endpoint: path, method: .get)
                request.setValue(token, forHTTPHeaderField: "token")
                
                guard let response = try await auraApiService.fetchAndDecode(AccountDetail.self, request: request) else { print("reponse de l api incorrecte"); return }
                
                self.transactions = response.transactions
                self.currentBalance = response.currentBalance
                
                print(AccountDetail.self)
            }
        }
    }
}

