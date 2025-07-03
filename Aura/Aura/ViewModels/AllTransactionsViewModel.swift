//
//  AllTransactionsViewModel.swift
//  Aura
//
//  Created by Renaud Leroy on 18/06/2025.
//

import Foundation

class AllTransactionsViewModel: ObservableObject {
    @Published var currentBalance: Double = 0.0
    @Published var transactions: [Transaction] = []
    @Published var errorMessage: String?
    
    struct AccountDetail : Decodable {
        let transactions: [Transaction]
        let currentBalance: Double
    }
    
    struct Transaction: Decodable {
        let label: String
        let value: Double
    }
    
    @MainActor
    func allTransactions() {
        let auraKeychainService = AuraKeychainService()
        let auraApiService = AuraAPIService()
        guard let token = try? auraKeychainService.getToken(key: "auth_token") else {
            return
        }
        
        Task {
            do {
                guard let path = try? AuraAPIService().createEndpoint(path: .fetchAccountsDetails) else {
                    return }
                    
                var request = AuraAPIService().createRequest(parameters: nil, jsonData: nil, endpoint: path, method: .get)
                request.setValue(token, forHTTPHeaderField: "token")
                guard let response = try await auraApiService.fetchAndDecode(AccountDetail.self, request: request) else { return
                }
                self.transactions = response.transactions
                self.currentBalance = response.currentBalance
            } catch {
                errorMessage = "Erreur lors du chargement des transactions"
            }
        }
    }
}

