//
//  OnboardingContainerView.swift
//  BonAcheter
//

import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var step: OnboardingStep = .language
    
    private enum OnboardingStep {
        case language, household, region
    }
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            Group {
                switch step {
                case .language:
                    LanguageOnboardingView(onNext: { step = .household })
                case .household:
                    HouseholdOnboardingView(onNext: { step = .region })
                case .region:
                    RegionView(mode: .onboarding(onNext: {
                        appState.phase = .main
                        appState.persist()
                    }))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        switch step {
                        case .language:
                            appState.phase = .landing
                            appState.persist()
                        case .household:
                            step = .language
                        case .region:
                            step = .household
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(s.onboardingBack)
                        }
                    }
                    .accessibilityIdentifier(UIAccessibilityID.onboardingBack)
                }
            }
        }
    }
}
