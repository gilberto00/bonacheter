//
//  EmailVerificationService.swift
//  BonAcheter
//
//  Device-local email verification: user sends themselves a mail with a signed link (bonacheter://).
//  Replace with Supabase Auth email confirmation for production.
//

import Foundation

extension Notification.Name {
    static let bonAcheterEmailVerified = Notification.Name("BonAcheter.emailVerified")
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    init?(base64URLEncoded string: String) {
        var s = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let pad = (4 - s.count % 4) % 4
        if pad > 0 { s += String(repeating: "=", count: pad) }
        self.init(base64Encoded: s)
    }
}

enum EmailVerificationService {
    private static let pendingIndexKey = "BonAcheter.pendingVerify.emails"
    private static func tokenKey(_ normalizedEmail: String) -> String {
        "BonAcheter.pendingVerify.tok.\(normalizedEmail)"
    }
    private static func expiryKey(_ normalizedEmail: String) -> String {
        "BonAcheter.pendingVerify.exp.\(normalizedEmail)"
    }
    
    /// Builds a fresh link and stores the token (24h validity).
    static func makeMagicLink(for normalizedEmail: String) -> URL {
        let token = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        storePendingToken(normalizedEmail: normalizedEmail, token: token)
        let tB64 = token.base64URLEncodedString()
        let eB64 = Data(normalizedEmail.utf8).base64URLEncodedString()
        var c = URLComponents()
        c.scheme = "bonacheter"
        c.host = "verify"
        c.queryItems = [
            URLQueryItem(name: "t", value: tB64),
            URLQueryItem(name: "e", value: eB64)
        ]
        guard let url = c.url else {
            fatalError("Invalid verification URL components")
        }
        return url
    }
    
    private static func storePendingToken(normalizedEmail: String, token: Data) {
        var emails = UserDefaults.standard.stringArray(forKey: pendingIndexKey) ?? []
        if !emails.contains(normalizedEmail) {
            emails.append(normalizedEmail)
            UserDefaults.standard.set(emails, forKey: pendingIndexKey)
        }
        let exp = Date().addingTimeInterval(24 * 3600).timeIntervalSince1970
        UserDefaults.standard.set(token, forKey: tokenKey(normalizedEmail))
        UserDefaults.standard.set(exp, forKey: expiryKey(normalizedEmail))
    }
    
    /// Validates the link, marks the account verified, clears pending token. Returns normalized email if successful.
    @discardableResult
    static func consumeVerificationURL(_ url: URL) -> String? {
        guard url.scheme?.lowercased() == "bonacheter", url.host?.lowercased() == "verify" else { return nil }
        guard
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let t = items.first(where: { $0.name == "t" })?.value,
            let e = items.first(where: { $0.name == "e" })?.value,
            let tokenData = Data(base64URLEncoded: t),
            let emailData = Data(base64URLEncoded: e),
            let rawEmail = String(data: emailData, encoding: .utf8)
        else { return nil }
        let norm = LocalCredentialStore.normalizedEmail(rawEmail)
        guard LocalCredentialStore.accountExists(for: norm) else { return nil }
        guard let stored = UserDefaults.standard.data(forKey: tokenKey(norm)),
              let exp = UserDefaults.standard.object(forKey: expiryKey(norm)) as? Double,
              Date().timeIntervalSince1970 <= exp
        else { return nil }
        guard stored.count == tokenData.count, stored == tokenData else { return nil }
        clearPending(for: norm)
        LocalCredentialStore.setEmailVerified(norm, verified: true)
        return norm
    }
    
    static func clearPending(for normalizedEmail: String) {
        let norm = LocalCredentialStore.normalizedEmail(normalizedEmail)
        UserDefaults.standard.removeObject(forKey: tokenKey(norm))
        UserDefaults.standard.removeObject(forKey: expiryKey(norm))
        var emails = UserDefaults.standard.stringArray(forKey: pendingIndexKey) ?? []
        emails.removeAll { $0 == norm }
        if emails.isEmpty {
            UserDefaults.standard.removeObject(forKey: pendingIndexKey)
        } else {
            UserDefaults.standard.set(emails, forKey: pendingIndexKey)
        }
    }
    
    static func wipeAllPending() {
        let emails = UserDefaults.standard.stringArray(forKey: pendingIndexKey) ?? []
        for e in emails {
            UserDefaults.standard.removeObject(forKey: tokenKey(e))
            UserDefaults.standard.removeObject(forKey: expiryKey(e))
        }
        UserDefaults.standard.removeObject(forKey: pendingIndexKey)
    }
    
    /// New verification mail body (localized subject/body assembled in the view).
    static func verificationMailBody(link: URL, strings: AppStrings) -> String {
        """
        \(strings.emailVerificationMailBodyIntro)
        
        \(link.absoluteString)
        
        \(strings.emailVerificationMailBodyOutro)
        """
    }
}
