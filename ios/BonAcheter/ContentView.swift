//
//  ContentView.swift
//  BonAcheter
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            switch appState.phase {
            case .landing:
                LandingView()
            case .onboarding:
                OnboardingContainerView()
            case .main:
                MainTabView()
            }
        }
        // Only force a locale refresh on main tabs; changing `.id` during onboarding would reset
        // `OnboardingContainerView` step (@State) right after picking a language (breaks flow + UI tests).
        .id(appState.phase == .main
            ? appState.languagePreference.rawValue + appState.resolvedLanguageCode
            : "phase-\(appState.phase.rawValue)")
    }
}

// MARK: - Main tab (Dashboard as home, then list accessible)
struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .accessibilityIdentifier(UIAccessibilityID.tabHome)
                .tabItem { Label(appState.strings.tabHome, systemImage: "house") }
                .tag(0)
            ListView()
                .accessibilityIdentifier(UIAccessibilityID.tabList)
                .tabItem { Label(appState.strings.tabList, systemImage: "list.bullet") }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
