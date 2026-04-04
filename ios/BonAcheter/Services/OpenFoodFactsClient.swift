//
//  OpenFoodFactsClient.swift
//  BonAcheter
//
//  Open Food Facts API — https://openfoodfacts.github.io/openfoodfacts-server/api/
//

import Foundation

/// Result of a successful barcode lookup (MVP: name + Québec tax hint).
struct ScannedProductResult: Sendable, Equatable {
    var productName: String
    var barcode: String
    /// Heuristic from OFF categories; user can override in the form.
    var suggestedTaxable: Bool
}

enum OpenFoodFactsError: LocalizedError {
    case invalidBarcode
    case notFound
    case invalidResponse
    case network(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidBarcode:
            return "Invalid barcode (need at least 8 digits)."
        case .notFound:
            return "Product not found in Open Food Facts."
        case .invalidResponse:
            return "Unexpected response from Open Food Facts."
        case .network(let e):
            return e.localizedDescription
        }
    }
}

/// Thin client for `GET /api/v0/product/{code}.json`.
struct OpenFoodFactsClient: Sendable {
    static let shared = OpenFoodFactsClient()
    
    private let session: URLSession = {
        let c = URLSessionConfiguration.ephemeral
        c.timeoutIntervalForRequest = 20
        c.timeoutIntervalForResource = 30
        return URLSession(configuration: c)
    }()
    
    private init() {}
    
    /// Normalizes barcode to digits only; requires length ≥ 8 (EAN-8+).
    func fetchProduct(barcode raw: String, preferredLanguageCode: String) async throws -> ScannedProductResult {
        let digits = raw.filter(\.isNumber)
        guard digits.count >= 8 else { throw OpenFoodFactsError.invalidBarcode }
        
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(digits).json") else {
            throw OpenFoodFactsError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.setValue(
            "BonAcheter-iOS/1.0 (https://github.com/bonacheter)",
            forHTTPHeaderField: "User-Agent"
        )
        
        let data: Data
        do {
            let (d, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw OpenFoodFactsError.invalidResponse
            }
            data = d
        } catch let e as OpenFoodFactsError {
            throw e
        } catch {
            throw OpenFoodFactsError.network(error)
        }
        
        let decoded = try JSONDecoder().decode(OFFAPIResponse.self, from: data)
        guard decoded.status == 1, let product = decoded.product else {
            throw OpenFoodFactsError.notFound
        }
        
        let name = product.bestDisplayName(preferredLang: preferredLanguageCode)
        let taxable = Self.inferTaxable(from: product.categories_tags ?? [])
        return ScannedProductResult(productName: name, barcode: digits, suggestedTaxable: taxable)
    }
    
    /// Québec-oriented heuristic: basic unprocessed foods often 0%; snacks/beverages often taxable.
    private static func inferTaxable(from tags: [String]) -> Bool {
        let blob = tags.joined(separator: " ").lowercased()
        let taxableHints = [
            "beverage", "snack", "candy", "chocolate", "soda", "soft-drink",
            "juice-drink", "chips", "cookie", "biscuit", "frozen-dessert",
            "ice-cream", "sweet-snack", "spread", "sauce"
        ]
        let zeroHints = [
            "fresh-fruits", "fresh-vegetables", "vegetables", "fruits",
            "meats", "fish", "milk", "eggs", "cheeses", "breads"
        ]
        if zeroHints.contains(where: { blob.contains($0) }) {
            if taxableHints.contains(where: { blob.contains($0) }) { return true }
            return false
        }
        if taxableHints.contains(where: { blob.contains($0) }) { return true }
        return true
    }
}

// MARK: - JSON

private struct OFFAPIResponse: Decodable {
    let status: Int
    let product: OFFProduct?
}

private struct OFFProduct: Decodable {
    let product_name: String?
    let product_name_en: String?
    let product_name_fr: String?
    let generic_name: String?
    let categories_tags: [String]?
    
    func bestDisplayName(preferredLang: String) -> String {
        let lang = preferredLang.lowercased()
        if lang.hasPrefix("fr"), let n = product_name_fr?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            return n
        }
        if let n = product_name_en?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            return n
        }
        if let n = product_name?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            return n
        }
        if let n = generic_name?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            return n
        }
        return "—"
    }
}
