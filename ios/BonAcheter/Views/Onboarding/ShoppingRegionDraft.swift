//
//  ShoppingRegionDraft.swift
//  BonAcheter
//

import Foundation

/// Editable shopping region for Québec MVP (Montérégie / CMM + city), persisted as a single display string.
struct ShoppingRegionDraft: Equatable {
    static let emDashSeparator = " — "
    
    static let defaultCities = ["Longueuil", "Saint-Jean-sur-Richelieu", "Montréal"]
    
    var isMonteregieEnabled: Bool
    var isCMMEnabled: Bool
    var city: String
    
    /// Parses `regionName` saved in `AppState`; falls back to both regions + first default city.
    static func parse(_ regionName: String) -> ShoppingRegionDraft {
        let trimmed = regionName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = trimmed.range(of: emDashSeparator) else {
            return Self(
                isMonteregieEnabled: true,
                isCMMEnabled: true,
                city: defaultCities[0]
            )
        }
        let regionsPart = String(trimmed[..<range.lowerBound])
        let cityPart = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let tokens = regionsPart.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var mon = false
        var cmm = false
        for t in tokens {
            if t == "Montérégie" { mon = true }
            if t == "CMM" { cmm = true }
        }
        if !mon && !cmm {
            mon = true
            cmm = true
        }
        let resolvedCity: String
        if cityPart.isEmpty {
            resolvedCity = defaultCities[0]
        } else {
            resolvedCity = cityPart
        }
        return ShoppingRegionDraft(
            isMonteregieEnabled: mon,
            isCMMEnabled: cmm,
            city: resolvedCity
        )
    }
    
    /// Cities shown in the picker, preserving unknown persisted values.
    var cityPickerOptions: [String] {
        var opts = Self.defaultCities
        if !opts.contains(city) {
            opts.append(city)
        }
        return opts
    }
    
    /// At least one of Montérégie / CMM must be on.
    func formattedRegionName() -> String? {
        var labels: [String] = []
        if isMonteregieEnabled { labels.append("Montérégie") }
        if isCMMEnabled { labels.append("CMM") }
        guard !labels.isEmpty else { return nil }
        return labels.joined(separator: ", ") + Self.emDashSeparator + city
    }
    
    var hasValidSelection: Bool { formattedRegionName() != nil }
}
