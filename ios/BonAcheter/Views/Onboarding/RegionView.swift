//
//  RegionView.swift
//  BonAcheter
//

import SwiftUI

struct RegionView: View {
    @Environment(AppState.self) private var appState
    var onNext: () -> Void
    @State private var isMonteregieEnabled = true
    @State private var isCMMEnabled = true
    @State private var city = "Longueuil"
    
    let cities = ["Longueuil", "Saint-Jean-sur-Richelieu", "Montréal"]
    
    var body: some View {
        let s = appState.strings
        Form {
            Section(s.regionCountry) {
                Text(s.regionCanadaQC)
                    .foregroundStyle(.secondary)
            }
            Section(s.regionRegions) {
                Toggle(s.regionMonteregieDisplayName, isOn: $isMonteregieEnabled)
                Toggle(s.regionCMMDisplayName, isOn: $isCMMEnabled)
            }
            Section(s.regionCity) {
                Picker(s.regionCity, selection: $city) {
                    ForEach(cities, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
            }
            Section {
                Button(s.regionContinue) {
                    appState.regionName = "Montérégie, CMM — \(city)"
                    appState.persist()
                    onNext()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .accessibilityIdentifier(UIAccessibilityID.regionContinue)
            }
        }
        .navigationTitle(s.regionTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RegionView(onNext: {})
    }
    .environment(AppState())
}
