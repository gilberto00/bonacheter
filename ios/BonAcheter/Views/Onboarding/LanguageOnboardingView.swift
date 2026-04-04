//
//  LanguageOnboardingView.swift
//  BonAcheter
//

import SwiftUI

struct LanguageOnboardingView: View {
    @Environment(AppState.self) private var appState
    var onNext: () -> Void
    
    var body: some View {
        let s = appState.strings
        VStack(spacing: 20) {
            Text(s.languageOnboardingHeadline)
                .font(.title)
                .fontWeight(.bold)
            
            Text(s.languageOnboardingSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(s.languageOnboardingHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(AppLanguagePreference.allCases, id: \.self) { pref in
                    Button {
                        appState.languagePreference = pref
                        appState.persist()
                        onNext()
                    } label: {
                        Text(s.languagePickerLabel(pref))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themePrimary)
                    .accessibilityIdentifier(UIAccessibilityID.onboardingLanguage(pref))
                }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .padding(.top, 48)
        .navigationTitle(s.languageOnboardingTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LanguageOnboardingView(onNext: {})
        .environment(AppState())
}
