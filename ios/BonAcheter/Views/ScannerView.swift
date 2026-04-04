//
//  ScannerView.swift
//  BonAcheter
//
//  Barcode lookup via Open Food Facts; camera UI is placeholder until AVFoundation wiring.
//

import SwiftUI

struct ScannerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    var onScanned: (ScannedProductResult) -> Void
    
    @State private var manualCode = ""
    @State private var isLookingUp = false
    @State private var lookupError: String?
    
    var body: some View {
        let s = appState.strings
        NavigationStack {
            Form {
                Section {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .foregroundStyle(.secondary)
                        .frame(height: 160)
                        .overlay {
                            Text(s.scannerCameraHint)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text(s.scannerTitle)
                }
                
                Section(s.scannerManualSection) {
                    TextField(s.scannerManualPlaceholder, text: $manualCode)
                        .keyboardType(.numberPad)
                    Button {
                        Task { await lookupFromField(s: s) }
                    } label: {
                        if isLookingUp {
                            HStack {
                                ProgressView()
                                Text(s.scannerLookupInProgress)
                            }
                        } else {
                            Text(s.scannerLookupButton)
                        }
                    }
                    .disabled(isLookingUp || manualCode.filter(\.isNumber).count < 8)
                }
                
                Section {
                    Button(s.scannerSimulate) {
                        let mock = ScannedProductResult(
                            productName: s.scannerMockProduct,
                            barcode: "3017620422003",
                            suggestedTaxable: true
                        )
                        onScanned(mock)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themePrimary)
                } footer: {
                    Text(s.scannerSimulateFooter)
                }
            }
            .navigationTitle(s.scannerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(s.scannerClose) { dismiss() }
                }
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
    }
    
    @MainActor
    private func lookupFromField(s: AppStrings) async {
        let digits = manualCode.filter(\.isNumber)
        guard digits.count >= 8 else {
            lookupError = s.scannerBarcodeTooShort
            return
        }
        isLookingUp = true
        lookupError = nil
        defer { isLookingUp = false }
        do {
            let result = try await OpenFoodFactsClient.shared.fetchProduct(
                barcode: digits,
                preferredLanguageCode: appState.resolvedLanguageCode
            )
            onScanned(result)
            dismiss()
        } catch {
            lookupError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

#Preview {
    ScannerView(onScanned: { _ in })
        .environment(AppState())
}
