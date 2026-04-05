//
//  SignUpView.swift
//  BonAcheter
//
//  Create a local account (email + password in Keychain). Server auth can replace this later.
//

import MessageUI
import SwiftUI

private struct MailComposePayload: Identifiable {
    let id = UUID()
    let recipients: [String]
    let subject: String
    let body: String
}

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var alertMessage: String?
    @State private var pendingVerification: (email: String, url: URL)?
    @State private var mailPayload: MailComposePayload?
    @State private var pastedLink = ""
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            Group {
                if let pending = pendingVerification {
                    verifyEmailContent(s: s, pending: pending)
                } else {
                    formContent(s: s)
                }
            }
            .navigationTitle(pendingVerification == nil ? s.signUpTitle : s.emailVerificationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(s.loginCancel) { dismiss() }
                        .accessibilityIdentifier(UIAccessibilityID.signUpCancel)
                }
            }
            .alert(s.signUpErrorTitle, isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button(s.alertDismissOK, role: .cancel) { alertMessage = nil }
            } message: {
                Text(alertMessage ?? "")
            }
            .sheet(item: $mailPayload) { payload in
                MailComposeView(
                    recipients: payload.recipients,
                    subject: payload.subject,
                    body: payload.body
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .bonAcheterEmailVerified)) { _ in
                pendingVerification = nil
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    private func formContent(s: AppStrings) -> some View {
        Form {
            Section {
                TextField(s.signUpEmailPlaceholder, text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier(UIAccessibilityID.signUpEmailField)
                SecureField(s.signUpPasswordPlaceholder, text: $password)
                    .textContentType(.newPassword)
                    .accessibilityIdentifier(UIAccessibilityID.signUpPasswordField)
                SecureField(s.signUpConfirmPasswordPlaceholder, text: $confirmPassword)
                    .textContentType(.newPassword)
                    .accessibilityIdentifier(UIAccessibilityID.signUpConfirmField)
            } footer: {
                Text(s.signUpPasswordRules)
            }
            Section {
                Button(s.signUpCreateButton) {
                    submit(s: s)
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .accessibilityIdentifier(UIAccessibilityID.signUpSubmit)
            }
        }
    }
    
    @ViewBuilder
    private func verifyEmailContent(s: AppStrings, pending: (email: String, url: URL)) -> some View {
        let canMail = MFMailComposeViewController.canSendMail()
        Form {
            Section {
                Text(s.emailVerificationInstructions(email: pending.email, canSendMail: canMail))
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            Section {
                if canMail {
                    Button(s.emailVerificationOpenMail) {
                        openMail(s: s, pending: pending)
                    }
                    .accessibilityIdentifier(UIAccessibilityID.signUpOpenMail)
                }
                ShareLink(item: pending.url, subject: Text(s.emailVerificationShareSubject), message: Text(s.emailVerificationShareMessage)) {
                    Label(s.emailVerificationShareLink, systemImage: "square.and.arrow.up")
                }
                Button(s.emailVerificationNewLink) {
                    let url = EmailVerificationService.makeMagicLink(for: pending.email)
                    pendingVerification = (pending.email, url)
                }
            }
            Section {
                TextField(s.emailVerificationPastePlaceholder, text: $pastedLink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier(UIAccessibilityID.signUpPasteVerifyLink)
                Button(s.emailVerificationPasteButton) {
                    tryPastedLink(s: s, beforePhase: appState.phase)
                }
            } footer: {
                Text(s.emailVerificationPasteFooter)
            }
        }
    }
    
    private func openMail(s: AppStrings, pending: (email: String, url: URL)) {
        let body = EmailVerificationService.verificationMailBody(link: pending.url, strings: s)
        mailPayload = MailComposePayload(
            recipients: [pending.email],
            subject: s.emailVerificationMailSubject,
            body: body
        )
    }
    
    private func tryPastedLink(s: AppStrings, beforePhase: AppPhase) {
        let t = pastedLink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let u = URL(string: t), u.scheme?.lowercased() == "bonacheter" else {
            alertMessage = s.emailVerificationInvalidLink
            return
        }
        appState.handleIncomingVerificationURL(u)
        if appState.phase == beforePhase {
            alertMessage = s.emailVerificationInvalidLink
        }
    }
    
    private func submit(s: AppStrings) {
        let result = appState.registerAccount(email: email, password: password, confirmPassword: confirmPassword)
        switch result {
        case .success:
            dismiss()
        case .pendingEmailVerification(let em, let url):
            pendingVerification = (em, url)
        case .accountAlreadyExists:
            alertMessage = s.signUpErrorAccountExists
        case .wrongPasswordUnverifiedAccount:
            alertMessage = s.signUpErrorWrongPasswordUnverified
        case .passwordMismatch:
            alertMessage = s.signUpErrorPasswordMismatch
        case .passwordTooShort:
            alertMessage = s.signUpErrorPasswordShort
        case .invalidEmail:
            alertMessage = s.signUpErrorInvalidEmail
        case .keychainFailed:
            alertMessage = s.signUpErrorKeychain
        }
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}
