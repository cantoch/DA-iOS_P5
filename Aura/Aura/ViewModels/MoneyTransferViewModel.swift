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
    
    struct TransferRequest: Encodable {
        let recipient : String
        let amount : String
    }
    
    @MainActor
    func sendMoney() {
        let auraKeychainService = AuraKeychainService()
        let auraApiService = AuraAPIService()
        let body = TransferRequest(recipient: recipient, amount: amount)
        guard let token = try? auraKeychainService.getToken(key: "auth_token") else {
            return
        }
        Task {
            do {
                let jsonData = try JSONEncoder().encode(body)
                let path = try! auraApiService.createEndpoint(path: .makeTransaction)
                var request = auraApiService.createRequest(parameters: nil, jsonData: nil, endpoint: path, method: .post)
                request.setValue(token, forHTTPHeaderField: "token")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
            } catch {
                print("Erreur réseau")
            }
        }
    }
}

//Format
//    {
//        "recipient": "+33 6 01 02 03 04",
//        "amount": 12.4
//    }

// Logic to send money - for now, we're just setting a success message.
// You can later integrate actual logic.
//    if !recipient.isEmpty && !amount.isEmpty {
//        transferMessage = "Successfully transferred \(amount) to \(recipient)"
//    } else {
//        transferMessage = "Please enter recipient and amount."
//    }
//}
//}
