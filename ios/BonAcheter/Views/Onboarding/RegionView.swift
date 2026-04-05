//
//  RegionView.swift
//  BonAcheter
//

import SwiftUI

struct RegionView: View {
    enum Mode {
        case onboarding(onNext: () -> Void)
        case settings
    }
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    
    @State private var draft = ShoppingRegionDraft(
        isMonteregieEnabled: true,
        isCMMEnabled: true,
        city: ShoppingRegionDraft.defaultCities[0]
    )
    
    var body: some View {
        let s = appState.strings
        Form {
            Section(s.regionCountry) {
                Text(s.regionCanadaQC)
                    .foregroundStyle(.secondary)
            }
            Section(s.regionRegions) {
                Toggle(s.regionMonteregieDisplayName, isOn: $draft.isMonteregieEnabled)
                Toggle(s.regionCMMDisplayName, isOn: $draft.isCMMEnabled)
            }
            Section(s.regionCity) {
                Picker(s.regionCity, selection: $draft.city) {
                    ForEach(draft.cityPickerOptions, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
            }
            if case .onboarding = mode {
                Section {
                    Button(s.regionContinue) {
                        applyDraftToAppState()
                        if case .onboarding(let onNext) = mode {
                            onNext()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .disabled(!draft.hasValidSelection)
                    .accessibilityIdentifier(UIAccessibilityID.regionContinue)
                }
            }
        }
        .navigationTitle(s.regionTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            draft = ShoppingRegionDraft.parse(appState.regionName)
        }
        .toolbar {
            if case .settings = mode {
                ToolbarItem(placement: .confirmationAction) {
                    Button(s.addItemSave) {
                        applyDraftToAppState()
                        dismiss()
                    }
                    .disabled(!draft.hasValidSelection)
                    .accessibilityIdentifier(UIAccessibilityID.settingsRegionSave)
                }
            }
        }
    }
    
    private func applyDraftToAppState() {
        guard let name = draft.formattedRegionName() else { return }
        appState.regionName = name
        appState.persist()
    }
}

#Preview("Onboarding") {
    NavigationStack {
        RegionView(mode: .onboarding(onNext: {}))
    }
    .environment(AppState())
}

#Preview("Settings") {
    NavigationStack {
        RegionView(mode: .settings)
    }
    .environment(AppState())
}
