//
//  TaxSourcesView.swift
//  BonAcheter
//

import SwiftUI

/// Static references aligned with `docs/architecture/consumption-taxes-quebec.md` and the HTML mockup.
struct TaxSourcesView: View {
    @Environment(AppState.self) private var appState
    
    private let rqCalculate = URL(string: "https://www.revenuquebec.ca/en/businesses/consumption-taxes/gsthst-and-qst/collecting-gst-and-qst/calculating-the-taxes/")!
    private let rqGrocery = URL(string: "https://www.revenuquebec.ca/en/businesses/consumption-taxes/gsthst-and-qst/special-cases-gsthst-and-qst/food-services-sector-applying-the-gst-and-qst/grocery-and-convenience-stores/")!
    private let rqFoodCitizen = URL(string: "https://www.revenuquebec.ca/fr/citoyens/taxes/biens-et-services-taxables-detaxes-ou-exoneres/tps-et-tvq/alimentation-produits-taxables-detaxes-ou-exoneres/")!
    private let craGst = URL(string: "https://www.canada.ca/en/revenue-agency/services/tax/businesses/topics/gst-hst-businesses.html")!
    
    var body: some View {
        let s = appState.strings
        Form {
            Section {
                Text(s.taxSourcesIntro1)
                Text(s.taxSourcesIntro2)
                Text(s.taxSourcesDocFooter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section(s.settingsTaxReferences) {
                Link(s.linkRevenuQuebecHome, destination: URL(string: "https://www.revenuquebec.ca")!)
                Link(s.linkRqCalculatingTaxes, destination: rqCalculate)
                Link(s.linkRevenuQuebecGroceryStores, destination: rqGrocery)
                Link(s.linkRevenuQuebecFood, destination: rqFoodCitizen)
                Link(s.linkCraHome, destination: craGst)
            }
        }
        .navigationTitle(s.taxSourcesTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TaxSourcesView()
            .environment(AppState())
    }
}
