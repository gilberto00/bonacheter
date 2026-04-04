//
//  HouseholdOnboardingView.swift
//  BonAcheter
//

import SwiftUI

struct HouseholdOnboardingView: View {
    @Environment(AppState.self) private var appState
    var onNext: () -> Void
    @State private var inviteCode = ""
    
    var body: some View {
        let s = appState.strings
        VStack(alignment: .leading, spacing: 20) {
            Text(s.household)
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(s.householdCreate) {
                appState.ensureHouseholdCreated()
                onNext()
            }
            .buttonStyle(.borderedProminent)
            .tint(themePrimary)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier(UIAccessibilityID.householdCreate)
            
            Text(s.householdOr)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
            
            TextField(s.householdInvitePlaceholder, text: $inviteCode)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier(UIAccessibilityID.householdInviteField)
            
            Button(s.householdJoin) {
                let n = Self.normalize(inviteCode)
                guard n.count >= 4 else { return }
                appState.joinHousehold(inviteCode: inviteCode)
                onNext()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
            .disabled(Self.normalize(inviteCode).count < 4)
            .accessibilityIdentifier(UIAccessibilityID.householdJoin)
            
            Spacer()
        }
        .padding(24)
        .navigationTitle(s.household)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private static func normalize(_ raw: String) -> String {
        raw.uppercased().filter { $0.isLetter || $0.isNumber }
    }
}

#Preview {
    NavigationStack {
        HouseholdOnboardingView(onNext: {})
    }
    .environment(AppState())
}
