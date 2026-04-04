//
//  GroceryMeasurement.swift
//  BonAcheter
//

import Foundation

/// Grocery quantity units: metric (Brazil & Canada norms) vs US customary.
enum GroceryMeasurementSystem: String, CaseIterable, Codable {
    /// SI-style units common in Brazil and Canada: L, ml, kg, g, plus count.
    case metricBrazilCanada
    /// US customary: lb, oz, fl oz, cup, liquid pt/qt/gal, plus count.
    case usCustomary
}

enum GroceryUnitCatalog {
    static func orderedUnitIds(for system: GroceryMeasurementSystem) -> [String] {
        switch system {
        case .metricBrazilCanada:
            return ["piece", "L", "ml", "kg", "g"]
        case .usCustomary:
            return ["piece", "lb", "oz", "fl_oz", "cup", "pt", "qt", "gal"]
        }
    }
    
    static func defaultUnitId(for system: GroceryMeasurementSystem) -> String {
        "piece"
    }
    
    static func isValid(unitId: String, system: GroceryMeasurementSystem) -> Bool {
        orderedUnitIds(for: system).contains(unitId)
    }
}
