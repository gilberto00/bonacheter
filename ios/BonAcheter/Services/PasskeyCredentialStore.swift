//
//  PasskeyCredentialStore.swift
//  BonAcheter
//
//  Maps WebAuthn credential IDs to normalized email (device Keychain). Server attestation should replace this for production.
//

import Foundation
import Security

enum PasskeyCredentialStore {
    private static let service = "com.bonacheter.app.passkeyMap"
    
    private static func accountKey(_ credentialID: Data) -> String {
        credentialID.base64EncodedString()
    }
    
    static func saveMapping(credentialID: Data, normalizedEmail: String) throws {
        let acc = accountKey(credentialID)
        deleteMapping(credentialID: credentialID)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: acc,
            kSecValueData as String: Data(normalizedEmail.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw PasskeyError.keychain(status)
        }
    }
    
    static func normalizedEmail(forCredentialID credentialID: Data) -> String? {
        let acc = accountKey(credentialID)
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: acc,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }
    
    static func deleteMapping(credentialID: Data) {
        let acc = accountKey(credentialID)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: acc
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    static func wipeAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum PasskeyError: LocalizedError {
    case keychain(OSStatus)
    case canceled
    case missingCredentialMapping
    case system(Error)
    
    var errorDescription: String? {
        switch self {
        case .canceled: return "Canceled"
        case .missingCredentialMapping: return "Passkey is not linked to this app."
        case .keychain: return "Could not update secure storage."
        case .system(let e): return e.localizedDescription
        }
    }
}
