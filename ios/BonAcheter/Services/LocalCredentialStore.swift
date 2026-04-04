//
//  LocalCredentialStore.swift
//  BonAcheter
//
//  Stores email + password hash in Keychain (device-only). Replace with Supabase Auth for production.
//

import CryptoKit
import Foundation
import Security

enum LocalCredentialError: LocalizedError, Equatable {
    case keychainFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .keychainFailed:
            return "Could not save credentials securely."
        }
    }
}

enum LocalCredentialStore {
    private static let service = "com.bonacheter.app.credentials"
    private static let verifiedService = "com.bonacheter.app.verifiedEmail"
    private static let webAuthnService = "com.bonacheter.app.webauthnUserID"
    
    static func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    /// Simple format check (not a full RFC parser).
    static func isValidEmailFormat(_ raw: String) -> Bool {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard s.count >= 5, s.contains("@") else { return false }
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
    
    private static func hashPassword(normalizedEmail: String, password: String) -> Data {
        let combined = "BonAcheter.v1|\(normalizedEmail)|\(password)"
        return Data(SHA256.hash(data: Data(combined.utf8)))
    }
    
    static func accountExists(for email: String) -> Bool {
        loadSecret(account: normalizedEmail(email)) != nil
    }
    
    /// `nil` = legacy account (created before verification existed) → treated as verified.
    private static func loadVerifiedByte(account: String) -> UInt8? {
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: verifiedService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, let b = data.first else { return nil }
        return b
    }
    
    /// Accounts without an explicit row are treated as verified (migration).
    static func isEmailVerified(_ email: String) -> Bool {
        let account = normalizedEmail(email)
        guard accountExists(for: account) else { return false }
        guard let b = loadVerifiedByte(account: account) else { return true }
        return b != 0
    }
    
    static func setEmailVerified(_ email: String, verified: Bool) {
        let account = normalizedEmail(email)
        deleteVerifiedRow(account: account)
        let data = Data([verified ? 1 : 0])
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: verifiedService,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private static func deleteVerifiedRow(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: verifiedService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    /// Stable opaque user handle for WebAuthn / Passkey registration.
    static func webAuthnUserID(for email: String) throws -> Data {
        let account = normalizedEmail(email)
        if let existing = loadWebAuthnUserID(account: account) { return existing }
        var bytes = [UInt8](repeating: 0, count: 32)
        let st = SecRandomCopyBytes(kSecRandomDefault, 32, &bytes)
        guard st == errSecSuccess else {
            throw LocalCredentialError.keychainFailed(OSStatus(st))
        }
        let data = Data(bytes)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: webAuthnService,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LocalCredentialError.keychainFailed(status)
        }
        return data
    }
    
    private static func loadWebAuthnUserID(account: String) -> Data? {
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: webAuthnService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }
    
    static func saveAccount(email: String, password: String) throws {
        let account = normalizedEmail(email)
        let secret = hashPassword(normalizedEmail: account, password: password)
        deleteAccount(email: email)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: secret,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw LocalCredentialError.keychainFailed(status)
        }
    }
    
    static func verify(email: String, password: String) -> Bool {
        let account = normalizedEmail(email)
        guard let stored = loadSecret(account: account) else { return false }
        let expected = hashPassword(normalizedEmail: account, password: password)
        return stored == expected
    }
    
    private static func loadSecret(account: String) -> Data? {
        var result: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }
    
    static func deleteAccount(email: String) {
        let account = normalizedEmail(email)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        deleteVerifiedRow(account: account)
        let wa: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: webAuthnService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(wa as CFDictionary)
    }
    
    /// Removes every auth-related Keychain row for this app (passwords, verification flags, WebAuthn user ids).
    static func wipeAll() {
        let cred: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(cred as CFDictionary)
        let ver: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: verifiedService
        ]
        SecItemDelete(ver as CFDictionary)
        let wa: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: webAuthnService
        ]
        SecItemDelete(wa as CFDictionary)
        PasskeyCredentialStore.wipeAll()
        EmailVerificationService.wipeAllPending()
    }
}
