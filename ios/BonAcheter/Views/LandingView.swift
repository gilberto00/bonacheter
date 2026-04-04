//
//  LandingView.swift
//  BonAcheter
//

import SwiftUI

struct LandingView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        let s = appState.strings
        VStack(spacing: 24) {
            Spacer()
            Text(s.landingTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(themePrimary)
            
            Text(s.landingSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(s.landingStart) {
                    appState.phase = .onboarding
                    appState.persist()
                }
                .buttonStyle(.borderedProminent)
                .tint(themePrimary)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(UIAccessibilityID.landingStart)
                
                Button(s.landingHaveAccount) {
                    showLogin = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(UIAccessibilityID.landingHaveAccount)
                
                Button(s.landingCreateAccount) {
                    showSignUp = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(UIAccessibilityID.landingCreateAccount)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
                .environment(appState)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environment(appState)
        }
    }
}

#Preview {
    LandingView()
        .environment(AppState())
}
