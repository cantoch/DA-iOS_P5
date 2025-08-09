//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    private let keychainService: AuraKeychainServiceProtocol
    private let apiService: AuraAPIServiceProtocol

    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var errorMessage: String?

    init(keychainService: AuraKeychainServiceProtocol, apiService: AuraAPIServiceProtocol) {
        self.keychainService = keychainService
        self.apiService = apiService
    }

    @MainActor
    func sendMoney() async {
        guard let amountToDecimal = convertToDecimal(amount) else {
            errorMessage = "Erreur de format"
            transferMessage = ""
            return
        }

        let body = TransferRequest(recipient: recipient, amount: amountToDecimal)

        guard let token = try? keychainService.getToken(key: "auth_token") else {
            errorMessage = "Echec d'identification"
            return
        }

        do {
            let jsonData = try JSONEncoder().encode(body)
            let path = try apiService.createEndpoint(path: .makeTransaction)
            var request = apiService.createRequest(jsonData: jsonData, endpoint: path, method: .post)
            request.setValue(token, forHTTPHeaderField: "token")
            _ = try await apiService.fetch(request: request, allowEmptyData: true)
            transferMessage = "Successfully transferred \(amount)€ to \(recipient)"
        } catch {
            errorMessage = "Erreur lors du transfert"
        }
    }

    func convertToDecimal(_ amount: String) -> Decimal? {
        guard let amountDecimal = Decimal(string: amount) else {
            return nil
        }
        return amountDecimal
    }
}


