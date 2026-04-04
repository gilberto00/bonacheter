//
//  LoginView.swift
//  BonAcheter
//
//  MVP: local “session” only (email stored on device). Replace with Sign in with Apple + Supabase Auth.
//

import MessageUI
import SwiftUI

private struct LoginMailPayload: Identifiable {
    let id = UUID()
    let recipients: [String]
    let subject: String
    let body: String
}

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var loginErrorMessage: String?
    @State private var emailAwaitingVerification: String?
    @State private var mailPayload: LoginMailPayload?
    @State private var passkeyBusy = false
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            Form {
                Section {
                    TextField(s.loginEmailPlaceholder, text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField(s.loginPasswordPlaceholder, text: $password)
                        .textContentType(.password)
                } footer: {
                    Text(s.loginFooter)
                }
                Section {
                    Button(s.loginSignIn) {
                        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, !password.isEmpty else {
                            loginErrorMessage = s.loginErrorMissingFields
                            emailAwaitingVerification = nil
                            return
                        }
                        switch appState.signInWithEmail(email: trimmed, password: password) {
                        case .success:
                            emailAwaitingVerification = nil
                            dismiss()
                        case .wrongCredentials:
                            emailAwaitingVerification = nil
                            loginErrorMessage = s.loginErrorWrongCredentials
                        case .emailNotVerified:
                            emailAwaitingVerification = LocalCredentialStore.normalizedEmail(trimmed)
                            loginErrorMessage = s.loginErrorEmailNotVerified
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier(UIAccessibilityID.loginSignIn)
                    
                    if let pending = emailAwaitingVerification,
                       LocalCredentialStore.normalizedEmail(email) == pending {
                        if MFMailComposeViewController.canSendMail() {
                            Button(s.emailVerificationResendMail) {
                                resendVerification(s: s, normalizedEmail: pending)
                            }
                        } else {
                            let url = EmailVerificationService.makeMagicLink(for: pending)
                            ShareLink(item: url, subject: Text(s.emailVerificationShareSubject), message: Text(s.emailVerificationShareMessage)) {
                                Label(s.emailVerificationResendMail, systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    
                    Button(s.loginWithPasskey) {
                        Task { await runPasskeySignIn(s: s) }
                    }
                    .disabled(passkeyBusy)
                    .accessibilityIdentifier(UIAccessibilityID.loginPasskey)
                    
                    Button(s.loginCreateAccountInstead) {
                        showSignUp = true
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier(UIAccessibilityID.loginOpenSignUp)
                }
            }
            .navigationTitle(s.loginTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.loginCancel) { dismiss() }
                        .accessibilityIdentifier(UIAccessibilityID.loginCancel)
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environment(appState)
            }
            .sheet(item: $mailPayload) { payload in
                MailComposeView(
                    recipients: payload.recipients,
                    subject: payload.subject,
                    body: payload.body
                )
            }
            .alert(s.signUpErrorTitle, isPresented: Binding(
                get: { loginErrorMessage != nil },
                set: { if !$0 { loginErrorMessage = nil } }
            )) {
                Button(s.alertDismissOK, role: .cancel) { loginErrorMessage = nil }
            } message: {
                Text(loginErrorMessage ?? "")
            }
        }
    }
    
    private func resendVerification(s: AppStrings, normalizedEmail: String) {
        guard LocalCredentialStore.accountExists(for: normalizedEmail) else { return }
        let url = EmailVerificationService.makeMagicLink(for: normalizedEmail)
        let body = EmailVerificationService.verificationMailBody(link: url, strings: s)
        mailPayload = LoginMailPayload(
            recipients: [normalizedEmail],
            subject: s.emailVerificationMailSubject,
            body: body
        )
    }
    
    @MainActor
    private func runPasskeySignIn(s: AppStrings) async {
        passkeyBusy = true
        defer { passkeyBusy = false }
        do {
            let norm = try await PasskeyAuthCoordinator.shared.signInWithPasskey()
            appState.signInWithPasskey(normalizedEmail: norm)
            dismiss()
        } catch {
            if let pe = error as? PasskeyError, case .canceled = pe { return }
            loginErrorMessage = s.loginPasskeyFailed + " \(error.localizedDescription)"
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
