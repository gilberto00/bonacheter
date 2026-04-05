//
//  AddItemView.swift
//  BonAcheter
//

import SwiftUI

struct AddItemView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var barcode = ""
    @State private var quantity = "1"
    @State private var unit = "piece"
    @State private var isTaxable = false
    @State private var taxCategorySource: TaxCategorySource = .manual
    @State private var showScanner = false
    @State private var isLookingUpOFF = false
    @State private var lookupError: String?
    @State private var howCategoryExpanded = false
    
    private var unitValues: [String] {
        GroceryUnitCatalog.orderedUnitIds(for: appState.measurementSystem)
    }
    
    var body: some View {
        let s = appState.strings
        Form {
            Section(s.addItemName) {
                TextField(s.addItemNamePlaceholder, text: $name)
                    .accessibilityIdentifier(UIAccessibilityID.addItemNameField)
            }
            Section(s.addItemBarcodeSection) {
                TextField(s.addItemBarcodePlaceholder, text: $barcode)
                    .keyboardType(.numberPad)
                HStack {
                    Button {
                        Task { await lookupOpenFoodFacts() }
                    } label: {
                        if isLookingUpOFF {
                            ProgressView()
                        } else {
                            Text(s.addItemLookupOFF)
                        }
                    }
                    .disabled(isLookingUpOFF || barcode.filter(\.isNumber).count < 8)
                }
            }
            Section(s.addItemQtyUnit) {
                HStack {
                    TextField("1", text: $quantity)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                    Picker(s.addItemUnitPicker, selection: $unit) {
                        ForEach(unitValues, id: \.self) { u in
                            Text(s.unitLabel(u)).tag(u)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            Section {
                Picker(s.addItemTaxCategory, selection: Binding(
                    get: { isTaxable },
                    set: { newValue in
                        isTaxable = newValue
                        taxCategorySource = .manual
                    }
                )) {
                    Text(s.addItemTaxZero).tag(false)
                    Text(s.addItemTaxable).tag(true)
                }
                .pickerStyle(.segmented)
            } header: {
                Text(s.addItemTax)
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(s.addItemTaxOriginTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(s.addItemTaxOriginBody(source: taxCategorySource, isTaxable: isTaxable))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(s.addItemTaxDisclaimer)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                DisclosureGroup(isExpanded: $howCategoryExpanded) {
                    Text(s.addItemTaxHowBody)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } label: {
                    Text(s.addItemTaxHowTitle)
                }
                NavigationLink {
                    TaxSourcesView()
                } label: {
                    Label(s.addItemTaxSourcesLink, systemImage: "info.circle")
                }
            }
            Section {
                Button {
                    showScanner = true
                } label: {
                    Label(s.addItemScan, systemImage: "barcode.viewfinder")
                }
                Button(s.addItemSave) {
                    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let digits = barcode.filter(\.isNumber)
                    let item = ListItem(
                        name: trimmedName.isEmpty ? s.addItemNewDefaultName : trimmedName,
                        quantity: quantity,
                        unit: unit,
                        isTaxable: isTaxable,
                        barcode: digits.isEmpty ? nil : digits,
                        taxCategorySource: taxCategorySource
                    )
                    appState.addListItem(item)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .disabled(!canSave(s: s))
                .accessibilityIdentifier(UIAccessibilityID.addItemSave)
            }
        }
        .navigationTitle(s.addItemTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !GroceryUnitCatalog.isValid(unitId: unit, system: appState.measurementSystem) {
                unit = GroceryUnitCatalog.defaultUnitId(for: appState.measurementSystem)
            }
        }
        .onChange(of: appState.measurementSystem) { _, newSystem in
            if !GroceryUnitCatalog.isValid(unitId: unit, system: newSystem) {
                unit = GroceryUnitCatalog.defaultUnitId(for: newSystem)
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView(onScanned: { result in
                name = result.productName
                barcode = result.barcode
                isTaxable = result.suggestedTaxable
                taxCategorySource = .openFoodFacts
                showScanner = false
            })
            .environment(appState)
        }
        .alert(s.scannerLookupFailed, isPresented: Binding(
            get: { lookupError != nil },
            set: { if !$0 { lookupError = nil } }
        )) {
            Button(s.scannerClose, role: .cancel) { lookupError = nil }
        } message: {
            Text(lookupError ?? "")
        }
    }
    
    private func canSave(s: AppStrings) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let digits = barcode.filter(\.isNumber)
        return !trimmedName.isEmpty || digits.count >= 8
    }
    
    @MainActor
    private func lookupOpenFoodFacts() async {
        let digits = barcode.filter(\.isNumber)
        guard digits.count >= 8 else {
            lookupError = appState.strings.scannerBarcodeTooShort
            return
        }
        isLookingUpOFF = true
        lookupError = nil
        defer { isLookingUpOFF = false }
        do {
            let result = try await OpenFoodFactsClient.shared.fetchProduct(
                barcode: digits,
                preferredLanguageCode: appState.resolvedLanguageCode
            )
            name = result.productName
            barcode = result.barcode
            isTaxable = result.suggestedTaxable
            taxCategorySource = .openFoodFacts
        } catch {
            lookupError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        AddItemView()
            .environment(AppState())
    }
}
