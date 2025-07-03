//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var errorMessage: String?
    
    struct TransferRequest: Encodable {
        let recipient : String
        let amount : Decimal
    }
    
    @MainActor
    func sendMoney() {
        let auraKeychainService = AuraKeychainService()
        let auraApiService = AuraAPIService()
        guard let amountToDecimal = convertToDecimal(amount) else {
            errorMessage = "Erreur de format"
            return
        }
        let body = TransferRequest(recipient: recipient, amount: amountToDecimal)
        guard let token = try? auraKeychainService.getToken(key: "auth_token") else {
            errorMessage = "Echec d'identification"
            return
        }
        Task {
            do {
                let jsonData = try JSONEncoder().encode(body)
                let path = try auraApiService.createEndpoint(path: .makeTransaction)
                var request = auraApiService.createRequest(parameters: nil, jsonData: nil, endpoint: path, method: .post)
                request.setValue(token, forHTTPHeaderField: "token")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                _ = try? await auraApiService.fetch(request: request, allowEmptyData: true)
            } catch {
                errorMessage = "Erreur lors du transfert"
            }
        }
    }
    
    func convertToDecimal(_ amount: String) -> Decimal? {
        guard let amountDecimal = Decimal(string: amount) else {
            return nil
        }
        return amountDecimal
    }
}

