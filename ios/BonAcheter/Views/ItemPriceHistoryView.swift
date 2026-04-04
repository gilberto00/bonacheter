//
//  ItemPriceHistoryView.swift
//  BonAcheter
//

import SwiftUI

struct ItemPriceHistoryView: View {
    @Environment(AppState.self) private var appState
    let item: ListItem
    
    private var stats: AppState.PriceStats {
        appState.priceStats(for: item.id)
    }
    
    private var entries: [PriceHistoryEntry] {
        appState.sortedHistory(for: item.id)
    }
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = appState.localeForFormatting
        return f
    }
    
    var body: some View {
        let s = appState.strings
        List {
            Section {
                if stats.count == 0 {
                    Text(s.historyEmpty)
                        .foregroundStyle(.secondary)
                } else {
                    LabeledContent(
                        s.historyAverage,
                        value: String(format: "%.2f $", stats.average ?? 0)
                    )
                    LabeledContent(
                        s.historyLowest,
                        value: String(format: "%.2f $", stats.min ?? 0)
                    )
                    LabeledContent(
                        s.historyHighest,
                        value: String(format: "%.2f $", stats.max ?? 0)
                    )
                    LabeledContent(
                        s.historyPurchases,
                        value: "\(stats.count)"
                    )
                }
            } header: {
                Text(s.historySummary)
            }
            
            if !entries.isEmpty {
                Section {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(dateFormatter.string(from: entry.date))
                                    .fontWeight(.medium)
                                Spacer()
                                Text(String(format: "%.2f $", entry.unitPrice))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(themePrimary)
                            }
                            Text(entry.storeName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text(s.historySection)
                }
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ItemPriceHistoryView(item: ListItem(name: "Lait 2%", quantity: "1", unit: "L", isTaxable: false))
            .environment(AppState())
    }
}
