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
        NavigationStack {
            Group {
                switch step {
                case .language:
                    LanguageOnboardingView(onNext: { step = .household })
                case .household:
                    HouseholdOnboardingView(onNext: { step = .region })
                case .region:
                    RegionView(onNext: {
                        appState.phase = .main
                        appState.persist()
                    })
                }
            }
        }
    }
}
