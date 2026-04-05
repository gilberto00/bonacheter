//
//  ListView.swift
//  BonAcheter
//

import SwiftUI

struct ListView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(s.listBudget)
                            Spacer()
                            Text(String(format: "%.0f $ / %.0f $", appState.spentThisPeriod, appState.budgetAmount))
                                .fontWeight(.semibold)
                                .foregroundStyle(themePrimary)
                        }
                        .font(.subheadline)
                        ProgressView(value: appState.spentThisPeriod / max(1, appState.budgetAmount))
                            .tint(themePrimary)
                        Text(s.budgetPeriod(appState.budgetPeriod))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(themePrimaryLight)
                }
                
                Section(s.listArticles) {
                    ForEach(appState.listItems) { item in
                        let stats = appState.priceStats(for: item.id)
                        NavigationLink {
                            ItemPriceHistoryView(item: item)
                        } label: {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .fontWeight(.medium)
                                    Text(listItemSubtitle(s: s, item: item))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if stats.count > 0, let avg = stats.average, let lo = stats.min, let hi = stats.max {
                                        Text(s.listPriceStats(avg: avg, min: lo, max: hi))
                                            .font(.caption2)
                                            .foregroundStyle(themePrimary)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: AddItemView()) {
                        Label(s.listAddItem, systemImage: "plus.circle.fill")
                            .fontWeight(.medium)
                    }
                    .accessibilityIdentifier(UIAccessibilityID.listAddItem)
                    NavigationLink(destination: RecordPurchaseView()) {
                        Text(s.listRecordPurchase)
                    }
                }
            }
            .navigationTitle(s.listTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier(UIAccessibilityID.listOpenSettings)
                }
            }
        }
    }
    
    private func listItemSubtitle(s: AppStrings, item: ListItem) -> String {
        var base = "\(item.quantity) \(s.unitLabel(item.unit)) · \(s.listTaxLine(isTaxable: item.isTaxable))"
        if let badge = s.listTaxSourceBadge(item.taxCategorySource) {
            base += " · " + badge
        }
        if let bc = item.barcode, !bc.isEmpty {
            return base + "\n" + s.listBarcodeLine(bc)
        }
        return base
    }
}

#Preview {
    ListView()
        .environment(AppState())
}
