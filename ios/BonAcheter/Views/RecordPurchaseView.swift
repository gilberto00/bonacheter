//
//  RecordPurchaseView.swift
//  BonAcheter
//

import SwiftUI

struct RecordPurchaseView: View {
    /// Shown in price history when the user leaves the store name blank.
    private static let unknownStorePlaceholder = "—"
    
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var storeName = ""
    @State private var selectedIds: Set<UUID> = []
    @State private var prices: [UUID: String] = [:]
    @State private var showCommunityConsent = false
    @State private var pendingCommunityEntries: [PriceHistoryEntry] = []
    
    var selectedItems: [ListItem] {
        appState.listItems.filter { selectedIds.contains($0.id) }
    }
    
    var subtotal: Double {
        selectedItems.compactMap { item in
            Double(prices[item.id] ?? "0") ?? 0
        }.reduce(0, +)
    }
    
    var taxAmount: Double {
        selectedItems.reduce(0) { sum, item in
            let p = Double(prices[item.id] ?? "0") ?? 0
            return sum + (item.isTaxable ? p * 0.1498 : 0)
        }
    }
    
    var total: Double { subtotal + taxAmount }
    
    private var historyEntries: [PriceHistoryEntry] {
        let store = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let label = store.isEmpty ? Self.unknownStorePlaceholder : store
        return selectedItems.compactMap { item in
            guard let p = Double(prices[item.id] ?? ""), p > 0 else { return nil }
            return PriceHistoryEntry(listItemId: item.id, storeName: label, unitPrice: p)
        }
    }
    
    private var hasPositivePriceLine: Bool {
        historyEntries.contains { $0.unitPrice > 0 }
    }
    
    private func completeAfterConsentChoice() {
        pendingCommunityEntries = []
        dismiss()
    }
    
    private func savePurchase() {
        let entries = historyEntries
        appState.registerPurchase(total: total, entries: entries)
        
        if appState.sharePriceWithCommunity == true {
            appState.submitCommunityPriceSnapshot(entries: entries)
        } else if appState.sharePriceWithCommunity == nil && hasPositivePriceLine {
            pendingCommunityEntries = entries
            showCommunityConsent = true
            return
        }
        dismiss()
    }
    
    var body: some View {
        let s = appState.strings
        Form {
            Section(s.recordStore) {
                TextField(s.recordStorePlaceholder, text: $storeName)
            }
            Section(s.recordItemsBought) {
                ForEach(appState.listItems) { item in
                    HStack {
                        Button {
                            if selectedIds.contains(item.id) {
                                selectedIds.remove(item.id)
                            } else {
                                selectedIds.insert(item.id)
                            }
                        } label: {
                            Image(systemName: selectedIds.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(themePrimary)
                        }
                        Text(item.name)
                        Spacer()
                        TextField(s.recordPricePlaceholder, text: Binding(
                            get: { prices[item.id] ?? "" },
                            set: { prices[item.id] = $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .frame(width: 70)
                        .multilineTextAlignment(.trailing)
                    }
                }
            }
            Section(s.recordRecap) {
                HStack { Text(s.recordSubtotal); Spacer(); Text(String(format: "%.2f $", subtotal)) }
                HStack { Text(s.recordTaxes); Spacer(); Text(String(format: "%.2f $", taxAmount)) }
                HStack {
                    Text(s.recordTotal)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.2f $", total))
                        .fontWeight(.semibold)
                }
            }
            Section {
                Button(s.recordSave) {
                    savePurchase()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .disabled(selectedIds.isEmpty)
            }
        }
        .navigationTitle(s.recordTitle)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            s.shareDialogTitle,
            isPresented: $showCommunityConsent,
            titleVisibility: .visible
        ) {
            Button(s.shareDialogYes) {
                appState.setSharePriceWithCommunity(true)
                appState.submitCommunityPriceSnapshot(entries: pendingCommunityEntries)
                completeAfterConsentChoice()
            }
            Button(s.shareDialogNo, role: .cancel) {
                appState.setSharePriceWithCommunity(false)
                completeAfterConsentChoice()
            }
        } message: {
            Text(s.shareDialogMessage)
        }
    }
}

#Preview {
    NavigationStack {
        RecordPurchaseView()
            .environment(AppState())
    }
}
