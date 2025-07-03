//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var currentBalance: Double = 0.0
    @Published var transactions: [Transaction] = []
    
    struct AccountDetail : Decodable {
        let transactions: [Transaction]
        let currentBalance: Double
    }
    
    struct Transaction: Decodable {
        let label: String
        let value: Double
    }
    
    @MainActor
    func account() {
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
                print("Erreur réseau")
            }
        }
    }
}

