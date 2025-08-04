//
//  Keychain.swift
//  Aura
//
//  Created by Renaud Leroy on 09/06/2025.
//

import Security
import Foundation

class AuraKeychainService: ObservableObject {
    
    // MARK: - KeychainError
    
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
        case unexpectedData
        
        var errorKeychainDescription: String? {
            switch self {
            case .itemNotFound:
                return "Item was not found"
            case .duplicateItem:
                return "Item already exists"
            case .unexpectedStatus(let OSStatus):
                return "Unexpected status: \(OSStatus)"
            case .unexpectedData:
                return "Unexpected data received"
            }
        }
    }
    
    // MARK: - Public Methods
    
    func saveToken(token: String, key: String) throws -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrAccount as String: key
        ]
        
        let tokenData = token.data(using: .utf8)!
        query[kSecValueData as String] = tokenData
        
        var existingItem: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &existingItem)

        if status == errSecSuccess {
            throw KeychainError.duplicateItem
        }
        
        let addStatus: OSStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.unexpectedStatus(addStatus)
        }
        return true
    }
    
    func getToken(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let item = item as? [String: Any],
              let tokenData = item[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        return token
    }
    
    func deleteToken(key: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
        return true
    }
}
