//
//  SettingsView.swift
//  BonAcheter
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var passkeyNotice: String?
    
    var body: some View {
        let s = appState.strings
        Form {
            if let email = appState.currentUserEmail {
                Section {
                    LabeledContent(s.settingsSignedInAs) {
                        Text(email)
                            .textSelection(.enabled)
                    }
                    if LocalCredentialStore.isEmailVerified(email) {
                        Button(s.settingsAddPasskey) {
                            Task { await registerPasskey(s: s, email: email) }
                        }
                    } else {
                        Text(s.settingsPasskeyNeedsVerifiedEmail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(s.settingsAccount)
                } footer: {
                    Text(s.settingsPasskeyFooter)
                }
            }
            Section(s.settingsRegion) {
                Text(appState.regionName)
                    .foregroundStyle(.secondary)
            }
            Section(s.settingsLanguage) {
                Picker(s.settingsLanguage, selection: Binding(
                    get: { appState.languagePreference },
                    set: {
                        appState.languagePreference = $0
                        appState.persist()
                    }
                )) {
                    ForEach(AppLanguagePreference.allCases, id: \.self) { pref in
                        Text(s.languagePickerLabel(pref)).tag(pref)
                    }
                }
                .pickerStyle(.menu)
            }
            Section {
                Picker(s.settingsMeasurementSection, selection: Binding(
                    get: { appState.measurementSystem },
                    set: {
                        appState.measurementSystem = $0
                        appState.persist()
                    }
                )) {
                    ForEach(GroceryMeasurementSystem.allCases, id: \.self) { system in
                        Text(s.measurementSystemLabel(system)).tag(system)
                    }
                }
                .pickerStyle(.menu)
            } footer: {
                Text(s.settingsMeasurementFooter)
            }
            Section {
                if let code = appState.householdInviteCode, !code.isEmpty {
                    LabeledContent(s.settingsInviteCodeLabel) {
                        Text(code)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                    }
                    ShareLink(item: code, subject: Text(s.settingsInviteShareSubject), message: Text(s.settingsInviteShareMessage)) {
                        Label(s.settingsInviteShare, systemImage: "square.and.arrow.up")
                    }
                    Button(s.settingsCopyInvite) {
                        UIPasteboard.general.string = code
                    }
                } else {
                    Text(s.settingsNoHouseholdCode)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(s.household)
            } footer: {
                Text(s.settingsHouseholdFooter)
            }
            Section {
                Toggle(isOn: Binding(
                    get: { appState.sharePriceWithCommunity ?? false },
                    set: { appState.setSharePriceWithCommunity($0) }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.settingsSharePricesTitle)
                        Text(s.settingsSharePricesFootnote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(s.settingsCommunity)
            }
            Section {
                NavigationLink {
                    TaxSourcesView()
                } label: {
                    Label(s.settingsTaxReferences, systemImage: "book.closed")
                }
            } footer: {
                Text(s.settingsTaxReferencesFootnote)
                    .font(.caption)
            }
            Section {
                Button(s.settingsSignOut, role: .destructive) {
                    appState.currentUserEmail = nil
                    appState.phase = .landing
                    appState.persist()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(s.settingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert(s.settingsTitle, isPresented: Binding(
            get: { passkeyNotice != nil },
            set: { if !$0 { passkeyNotice = nil } }
        )) {
            Button(s.alertDismissOK, role: .cancel) { passkeyNotice = nil }
        } message: {
            Text(passkeyNotice ?? "")
        }
    }
    
    @MainActor
    private func registerPasskey(s: AppStrings, email: String) async {
        do {
            try await PasskeyAuthCoordinator.shared.registerPasskey(
                normalizedEmail: LocalCredentialStore.normalizedEmail(email),
                displayName: email
            )
            passkeyNotice = s.settingsPasskeyAdded
        } catch {
            if let pe = error as? PasskeyError, case .canceled = pe { return }
            passkeyNotice = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppState())
    }
}
