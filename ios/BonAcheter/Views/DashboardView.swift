//
//  DashboardView.swift
//  BonAcheter
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    
    var remaining: Double {
        max(0, appState.budgetAmount - appState.spentThisPeriod)
    }
    
    var progress: Double {
        guard appState.budgetAmount > 0 else { return 0 }
        return min(1, appState.spentThisPeriod / appState.budgetAmount)
    }
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(s.dashboardBudgetPeriod)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(s.dashboardRemaining(remaining, appState.budgetAmount))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(themePrimary)
                        ProgressView(value: progress)
                            .tint(themePrimary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(themePrimaryLight)
                }
                
                Section(s.dashboardQuickAccess) {
                    NavigationLink(destination: ListView()) {
                        Label(s.dashboardMyList, systemImage: "list.bullet")
                    }
                    NavigationLink(destination: BudgetView()) {
                        Label(s.dashboardBudget, systemImage: "dollarsign.circle")
                    }
                    NavigationLink(destination: RecordPurchaseView()) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label(s.dashboardLastTrip, systemImage: "cart")
                            Text(s.dashboardLastTripMock)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink(destination: SettingsView()) {
                        Label(s.dashboardSettings, systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle(s.dashboardTitle)
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
}
