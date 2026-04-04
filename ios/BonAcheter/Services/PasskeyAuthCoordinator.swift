//
//  PasskeyAuthCoordinator.swift
//  BonAcheter
//
//  Registration (signed-in, verified email) and passwordless sign-in via ASAuthorization (Passkeys).
//

import AuthenticationServices
import Foundation
import UIKit

@MainActor
final class PasskeyAuthCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = PasskeyAuthCoordinator()
    
    private var registrationContinuation: CheckedContinuation<Void, Error>?
    private var assertionContinuation: CheckedContinuation<String, Error>?
    private var pendingRegistrationEmail: String?
    
    private override init() {
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let ordered = scenes.sorted { a, b in
            if a.activationState == .foregroundActive && b.activationState != .foregroundActive { return true }
            return false
        }
        for scene in ordered {
            if let w = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
                return w
            }
        }
        if let w = scenes.flatMap(\.windows).first {
            return w
        }
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let reg = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            finishRegistration(reg)
            return
        }
        if let assertion = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            finishAssertion(assertion)
            return
        }
        registrationContinuation?.resume(throwing: PasskeyError.system(NSError(domain: "BonAcheter.Passkey", code: 1)))
        registrationContinuation = nil
        assertionContinuation?.resume(throwing: PasskeyError.system(NSError(domain: "BonAcheter.Passkey", code: 1)))
        assertionContinuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let ns = error as NSError
        if ns.domain == ASAuthorizationError.errorDomain, ns.code == ASAuthorizationError.canceled.rawValue {
            registrationContinuation?.resume(throwing: PasskeyError.canceled)
            assertionContinuation?.resume(throwing: PasskeyError.canceled)
        } else {
            registrationContinuation?.resume(throwing: PasskeyError.system(error))
            assertionContinuation?.resume(throwing: PasskeyError.system(error))
        }
        registrationContinuation = nil
        assertionContinuation = nil
        pendingRegistrationEmail = nil
    }
    
    private func randomChallenge() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, 32, &bytes)
        return Data(bytes)
    }
    
    /// Register a passkey for the current account (email must be verified).
    func registerPasskey(normalizedEmail: String, displayName: String) async throws {
        pendingRegistrationEmail = normalizedEmail
        let userID = try LocalCredentialStore.webAuthnUserID(for: normalizedEmail)
        let challenge = randomChallenge()
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: PasskeyConfiguration.relyingPartyID)
        let request = provider.createCredentialRegistrationRequest(challenge: challenge, name: displayName, userID: userID)
        request.userVerificationPreference = .preferred
        
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            self.registrationContinuation = cont
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    private func finishRegistration(_ reg: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        defer {
            registrationContinuation = nil
            pendingRegistrationEmail = nil
        }
        guard let email = pendingRegistrationEmail else {
            registrationContinuation?.resume(throwing: PasskeyError.system(NSError(domain: "BonAcheter.Passkey", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing email context"])))
            return
        }
        do {
            try PasskeyCredentialStore.saveMapping(credentialID: reg.credentialID, normalizedEmail: email)
            registrationContinuation?.resume()
        } catch {
            registrationContinuation?.resume(throwing: error)
        }
    }
    
    /// Discoverable passkey sign-in; returns normalized email when a mapped credential is used.
    func signInWithPasskey() async throws -> String {
        let challenge = randomChallenge()
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: PasskeyConfiguration.relyingPartyID)
        let request = provider.createCredentialAssertionRequest(challenge: challenge)
        request.userVerificationPreference = .preferred
        
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            self.assertionContinuation = cont
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    private func finishAssertion(_ assertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        defer { assertionContinuation = nil }
        guard let email = PasskeyCredentialStore.normalizedEmail(forCredentialID: assertion.credentialID) else {
            assertionContinuation?.resume(throwing: PasskeyError.missingCredentialMapping)
            return
        }
        guard LocalCredentialStore.accountExists(for: email) else {
            assertionContinuation?.resume(throwing: PasskeyError.missingCredentialMapping)
            return
        }
        assertionContinuation?.resume(returning: email)
    }
}
