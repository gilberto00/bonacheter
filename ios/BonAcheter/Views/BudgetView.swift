//
//  BudgetView.swift
//  BonAcheter
//

import SwiftUI

struct BudgetView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var period: BudgetPeriod = .biweekly
    @State private var amount: String = "200"
    
    var body: some View {
        let s = appState.strings
        Form {
            Section(s.budgetPeriodSection) {
                Picker(s.budgetPeriodSection, selection: $period) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { p in
                        Text(s.budgetPeriod(p)).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: period) { _, new in
                    appState.budgetPeriod = new
                    appState.persist()
                }
            }
            Section(s.budgetAmountSection) {
                TextField("200", text: $amount)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { _, new in
                        if let v = Double(new.replacingOccurrences(of: ",", with: ".")) {
                            appState.budgetAmount = v
                            appState.persist()
                        }
                    }
            }
            Section {
                Text(s.budgetRemainingLine(max(0, appState.budgetAmount - appState.spentThisPeriod)))
                    .foregroundStyle(.secondary)
            }
            Section {
                Button(s.budgetSave) {
                    if let v = Double(amount) { appState.budgetAmount = v }
                    appState.budgetPeriod = period
                    appState.persist()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
            }
        }
        .navigationTitle(s.budgetTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            period = appState.budgetPeriod
            amount = String(format: "%.0f", appState.budgetAmount)
        }
    }
}

#Preview {
    NavigationStack {
        BudgetView()
            .environment(AppState())
    }
}
