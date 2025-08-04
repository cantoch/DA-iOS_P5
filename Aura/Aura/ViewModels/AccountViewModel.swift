//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountViewModel: ObservableObject {
    private let keychainService: AuraKeychainServiceProtocol
    private let apiService: AuraAPIServiceProtocol
    
    @Published var currentBalance: Double = 0.0
    @Published var transactions: [Transaction] = []
    
    init(keychainService: AuraKeychainServiceProtocol, apiService: AuraAPIServiceProtocol) {
        self.keychainService = keychainService
        self.apiService = apiService
    }
    
    @MainActor
    func account() async {
        guard let token = try? keychainService.getToken(key: "auth_token") else {
            return
        }
        do {
            guard let path = try? apiService.createEndpoint(path: .fetchAccountsDetails) else {
                return
            }
            var request = apiService.createRequest(parameters: nil, jsonData: nil, endpoint: path, method: .get)
            request.setValue(token, forHTTPHeaderField: "token")
            guard let response = try await apiService.fetchAndDecode(AccountDetail.self, request: request, allowEmptyData: false) else {
                return
            }
            self.transactions = response.transactions
            self.currentBalance = response.currentBalance
        } catch {
            print("Erreur réseau")
        }
    }
}


