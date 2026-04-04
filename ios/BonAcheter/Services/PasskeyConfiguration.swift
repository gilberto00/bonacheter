//
//  PasskeyConfiguration.swift
//  BonAcheter
//
//  Relying Party ID must match Associated Domains (webcredentials:…).
//  Host `apple-app-site-association` on HTTPS for production; use ?mode=developer in entitlements while developing.
//

import Foundation

enum PasskeyConfiguration {
    /// Override via Info.plist key `PasskeyRelyingPartyID` (e.g. your domain without scheme).
    static var relyingPartyID: String {
        if let s = Bundle.main.object(forInfoDictionaryKey: "PasskeyRelyingPartyID") as? String,
           !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "bonacheter.app"
    }
}
