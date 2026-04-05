//
//  BonAcheterApp.swift
//  BonAcheter
//
//  Wireframe / prototype — shared grocery list, budget, Québec taxes.
//

import SwiftUI

@main
struct BonAcheterApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onOpenURL { appState.handleIncomingVerificationURL($0) }
        }
    }
}

// MARK: - App phase

enum AppPhase: String, CaseIterable, Codable {
    case landing
    case onboarding
    case main
}

// MARK: - Price history

struct PriceHistoryEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var listItemId: UUID
    var date: Date
    var storeName: String
    var unitPrice: Double
    
    init(
        id: UUID = UUID(),
        listItemId: UUID,
        date: Date = Date(),
        storeName: String,
        unitPrice: Double
    ) {
        self.id = id
        self.listItemId = listItemId
        self.date = date
        self.storeName = storeName
        self.unitPrice = unitPrice
    }
}

// MARK: - List item (stable id for persistence / history)

struct ListItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var quantity: String
    var unit: String
    var isTaxable: Bool
    /// EAN/UPC digits when known (Open Food Facts lookup).
    var barcode: String?
    
    init(id: UUID = UUID(), name: String, quantity: String, unit: String, isTaxable: Bool, barcode: String? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isTaxable = isTaxable
        self.barcode = barcode
    }
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case biweekly = "Bi-hebdo"
    case monthly = "Mensuel"
}

/// Legacy storage before `AppLanguagePreference` (raw value was the old picker label).
private enum LegacyLanguage: String, Codable {
    case fr = "Français"
    case en = "English"
}

// MARK: - Persistence payload

private struct PersistedState: Codable {
    var phase: AppPhase
    var languagePreference: AppLanguagePreference
    var regionName: String
    var budgetPeriod: BudgetPeriod
    var budgetAmount: Double
    var spentThisPeriod: Double
    var listItems: [ListItem]
    /// UUID strings as keys for portability with JSON/UserDefaults.
    var priceHistoryKeys: [String: [PriceHistoryEntry]]
    var sharePriceWithCommunity: Bool?
    var measurementSystem: GroceryMeasurementSystem
    /// Short code shared with family; used as sync key until Supabase row IDs exist.
    var householdInviteCode: String?
    /// Local MVP “session” (replace with Supabase Auth).
    var currentUserEmail: String?
    
    enum CodingKeys: String, CodingKey {
        case phase, languagePreference, language, regionName, budgetPeriod, budgetAmount, spentThisPeriod, listItems, priceHistoryKeys, sharePriceWithCommunity, measurementSystem
        case householdInviteCode, currentUserEmail
    }
    
    init(
        phase: AppPhase,
        languagePreference: AppLanguagePreference,
        regionName: String,
        budgetPeriod: BudgetPeriod,
        budgetAmount: Double,
        spentThisPeriod: Double,
        listItems: [ListItem],
        priceHistoryKeys: [String: [PriceHistoryEntry]],
        sharePriceWithCommunity: Bool?,
        measurementSystem: GroceryMeasurementSystem,
        householdInviteCode: String?,
        currentUserEmail: String?
    ) {
        self.phase = phase
        self.languagePreference = languagePreference
        self.regionName = regionName
        self.budgetPeriod = budgetPeriod
        self.budgetAmount = budgetAmount
        self.spentThisPeriod = spentThisPeriod
        self.listItems = listItems
        self.priceHistoryKeys = priceHistoryKeys
        self.sharePriceWithCommunity = sharePriceWithCommunity
        self.measurementSystem = measurementSystem
        self.householdInviteCode = householdInviteCode
        self.currentUserEmail = currentUserEmail
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        phase = try c.decode(AppPhase.self, forKey: .phase)
        if let pref = try c.decodeIfPresent(AppLanguagePreference.self, forKey: .languagePreference) {
            languagePreference = pref
        } else if let legacy = try c.decodeIfPresent(LegacyLanguage.self, forKey: .language) {
            languagePreference = legacy == .fr ? .french : .english
        } else {
            languagePreference = .system
        }
        regionName = try c.decode(String.self, forKey: .regionName)
        budgetPeriod = try c.decode(BudgetPeriod.self, forKey: .budgetPeriod)
        budgetAmount = try c.decode(Double.self, forKey: .budgetAmount)
        spentThisPeriod = try c.decode(Double.self, forKey: .spentThisPeriod)
        listItems = try c.decode([ListItem].self, forKey: .listItems)
        priceHistoryKeys = try c.decode([String: [PriceHistoryEntry]].self, forKey: .priceHistoryKeys)
        sharePriceWithCommunity = try c.decodeIfPresent(Bool.self, forKey: .sharePriceWithCommunity)
        measurementSystem = try c.decodeIfPresent(GroceryMeasurementSystem.self, forKey: .measurementSystem) ?? .metricBrazilCanada
        householdInviteCode = try c.decodeIfPresent(String.self, forKey: .householdInviteCode)
        currentUserEmail = try c.decodeIfPresent(String.self, forKey: .currentUserEmail)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(phase, forKey: .phase)
        try c.encode(languagePreference, forKey: .languagePreference)
        try c.encode(regionName, forKey: .regionName)
        try c.encode(budgetPeriod, forKey: .budgetPeriod)
        try c.encode(budgetAmount, forKey: .budgetAmount)
        try c.encode(spentThisPeriod, forKey: .spentThisPeriod)
        try c.encode(listItems, forKey: .listItems)
        try c.encode(priceHistoryKeys, forKey: .priceHistoryKeys)
        try c.encodeIfPresent(sharePriceWithCommunity, forKey: .sharePriceWithCommunity)
        try c.encode(measurementSystem, forKey: .measurementSystem)
        try c.encodeIfPresent(householdInviteCode, forKey: .householdInviteCode)
        try c.encodeIfPresent(currentUserEmail, forKey: .currentUserEmail)
    }
}

private enum AppPersistence {
    static let key = "BonAcheter.persistedState"
    
    static func load() -> PersistedState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }
    
    static func save(_ state: PersistedState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - Local account (email + Keychain)

enum LocalAccountRegistrationResult: Equatable {
    case success
    /// User must open the verification link (e-mail) before signing in.
    case pendingEmailVerification(email: String, verificationURL: URL)
    case invalidEmail
    case passwordTooShort
    case passwordMismatch
    case accountAlreadyExists
    /// Same email exists but not verified; password did not match (cannot resend link from sign-up).
    case wrongPasswordUnverifiedAccount
    case keychainFailed
}

enum EmailPasswordSignInResult: Equatable {
    case success
    case wrongCredentials
    case emailNotVerified
}

// MARK: - App state

@Observable
final class AppState {
    /// Used by tests and `-uiTestSkipEmailVerification` so flows can run without Mail.
    static var shouldSkipEmailVerification: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestSkipEmailVerification")
            || UserDefaults.standard.bool(forKey: "BonAcheter.tests.skipEmailVerification")
    }
    
    var phase: AppPhase
    /// Fixed locale, or `.system` to follow iOS preferred languages.
    var languagePreference: AppLanguagePreference
    var regionName: String
    var budgetPeriod: BudgetPeriod
    var budgetAmount: Double
    var spentThisPeriod: Double
    var listItems: [ListItem]
    /// Price points keyed by list item id (local history only).
    private(set) var priceHistoryByItemId: [UUID: [PriceHistoryEntry]]
    /// `nil` = not asked yet; contributes anonymized price snapshots when `true`.
    var sharePriceWithCommunity: Bool?
    /// Metric (Brazil & Canada) vs US customary units for new items and pickers.
    var measurementSystem: GroceryMeasurementSystem
    /// Invite / household sync key (local MVP; same code on two devices = same group when backend ships).
    var householdInviteCode: String?
    /// Stored email for MVP login UI (no server verification).
    var currentUserEmail: String?
    
    private let listSync: ListSyncServicing = LocalOnlyListSyncService()
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            UserDefaults.standard.removeObject(forKey: AppPersistence.key)
            UserDefaults.standard.removeObject(forKey: "BonAcheter.tests.skipEmailVerification")
            LocalCredentialStore.wipeAll()
        }
        if let saved = AppPersistence.load() {
            phase = saved.phase
            languagePreference = saved.languagePreference
            regionName = saved.regionName
            budgetPeriod = saved.budgetPeriod
            budgetAmount = saved.budgetAmount
            spentThisPeriod = saved.spentThisPeriod
            listItems = saved.listItems
            sharePriceWithCommunity = saved.sharePriceWithCommunity
            measurementSystem = saved.measurementSystem
            householdInviteCode = saved.householdInviteCode
            currentUserEmail = saved.currentUserEmail
            var byId: [UUID: [PriceHistoryEntry]] = [:]
            for (key, entries) in saved.priceHistoryKeys {
                guard let uuid = UUID(uuidString: key) else { continue }
                byId[uuid] = entries
            }
            priceHistoryByItemId = byId
        } else {
            phase = .landing
            languagePreference = .system
            regionName = "Montérégie, CMM — Longueuil"
            budgetPeriod = .biweekly
            budgetAmount = 200
            spentThisPeriod = 120
            listItems = Self.defaultSeedListItems
            priceHistoryByItemId = [:]
            sharePriceWithCommunity = nil
            measurementSystem = .metricBrazilCanada
            householdInviteCode = nil
            currentUserEmail = nil
        }
        restartListSync()
    }
    
    /// Fixed ids so seed demo items keep stable history across first installs (until user clears data).
    private static let defaultSeedListItems: [ListItem] = [
        ListItem(
            id: UUID(uuidString: "A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D")!,
            name: "Lait 2%",
            quantity: "1",
            unit: "L",
            isTaxable: false
        ),
        ListItem(
            id: UUID(uuidString: "B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E")!,
            name: "Pain brun",
            quantity: "1",
            unit: "piece",
            isTaxable: false
        ),
        ListItem(
            id: UUID(uuidString: "C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F")!,
            name: "Yogourt",
            quantity: "2",
            unit: "piece",
            isTaxable: true
        )
    ]
    
    func persist() {
        var keys: [String: [PriceHistoryEntry]] = [:]
        for (id, entries) in priceHistoryByItemId {
            keys[id.uuidString] = entries
        }
        let payload = PersistedState(
            phase: phase,
            languagePreference: languagePreference,
            regionName: regionName,
            budgetPeriod: budgetPeriod,
            budgetAmount: budgetAmount,
            spentThisPeriod: spentThisPeriod,
            listItems: listItems,
            priceHistoryKeys: keys,
            sharePriceWithCommunity: sharePriceWithCommunity,
            measurementSystem: measurementSystem,
            householdInviteCode: householdInviteCode,
            currentUserEmail: currentUserEmail
        )
        AppPersistence.save(payload)
    }
    
    private func restartListSync() {
        listSync.stop()
        if let code = householdInviteCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty {
            listSync.start(householdId: code) { _ in }
        }
    }
    
    /// Creates a new invite code if none exists (onboarding “Create household”).
    func ensureHouseholdCreated() {
        if let c = householdInviteCode?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty {
            restartListSync()
            return
        }
        householdInviteCode = Self.makeInviteCode()
        persist()
        restartListSync()
    }
    
    /// Joins an existing household by invite code (local key until backend validates).
    func joinHousehold(inviteCode raw: String) {
        let normalized = Self.normalizeInviteCode(raw)
        guard normalized.count >= 4 else { return }
        householdInviteCode = normalized
        persist()
        restartListSync()
    }
    
    private static let inviteAlphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    
    private static func makeInviteCode() -> String {
        String((0..<6).map { _ in inviteAlphabet.randomElement()! })
    }
    
    private static func normalizeInviteCode(_ raw: String) -> String {
        raw.uppercased().filter { $0.isLetter || $0.isNumber }
    }
    
    struct PriceStats {
        var average: Double?
        var min: Double?
        var max: Double?
        var count: Int
    }
    
    func priceStats(for itemId: UUID) -> PriceStats {
        let prices = (priceHistoryByItemId[itemId] ?? []).map(\.unitPrice).filter { $0 > 0 }
        guard !prices.isEmpty else {
            return PriceStats(average: nil, min: nil, max: nil, count: 0)
        }
        let sum = prices.reduce(0, +)
        return PriceStats(
            average: sum / Double(prices.count),
            min: prices.min(),
            max: prices.max(),
            count: prices.count
        )
    }
    
    func sortedHistory(for itemId: UUID) -> [PriceHistoryEntry] {
        (priceHistoryByItemId[itemId] ?? []).sorted { $0.date > $1.date }
    }
    
    func ensurePriceInsights(for itemId: UUID) {
        // Local rows are keyed by item id; reserved for future remote prefetch (e.g. EAN, community API).
        _ = priceStats(for: itemId)
    }
    
    func addListItem(_ item: ListItem) {
        listItems.append(item)
        ensurePriceInsights(for: item.id)
        persist()
        listSync.publishList(listItems)
    }
    
    /// Updates running spend, appends price rows, saves once.
    func registerPurchase(total: Double, entries: [PriceHistoryEntry]) {
        spentThisPeriod += total
        if !entries.isEmpty {
            for e in entries {
                priceHistoryByItemId[e.listItemId, default: []].append(e)
            }
        }
        persist()
    }
    
    /// When user opts in to community sharing; no network in prototype.
    func submitCommunityPriceSnapshot(entries: [PriceHistoryEntry]) {
        guard sharePriceWithCommunity == true else { return }
        // TODO: POST anonymized aggregates when API exists
        _ = entries
    }
    
    func setSharePriceWithCommunity(_ value: Bool?) {
        sharePriceWithCommunity = value
        persist()
    }
    
    /// Registers a new account on this device (Keychain). If the email exists but is still unverified and the password matches, issues a new verification link instead of failing.
    func registerAccount(email: String, password: String, confirmPassword: String) -> LocalAccountRegistrationResult {
        let em = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard LocalCredentialStore.isValidEmailFormat(em) else { return .invalidEmail }
        guard password.count >= 8 else { return .passwordTooShort }
        guard password == confirmPassword else { return .passwordMismatch }
        let norm = LocalCredentialStore.normalizedEmail(em)
        if LocalCredentialStore.accountExists(for: em) {
            if LocalCredentialStore.isEmailVerified(norm) {
                return .accountAlreadyExists
            }
            guard LocalCredentialStore.verify(email: em, password: password) else {
                return .wrongPasswordUnverifiedAccount
            }
            let url = EmailVerificationService.makeMagicLink(for: norm)
            return .pendingEmailVerification(email: norm, verificationURL: url)
        }
        do {
            try LocalCredentialStore.saveAccount(email: em, password: password)
        } catch {
            return .keychainFailed
        }
        if Self.shouldSkipEmailVerification {
            LocalCredentialStore.setEmailVerified(norm, verified: true)
            currentUserEmail = norm
            phase = .main
            persist()
            return .success
        }
        LocalCredentialStore.setEmailVerified(norm, verified: false)
        let url = EmailVerificationService.makeMagicLink(for: norm)
        return .pendingEmailVerification(email: norm, verificationURL: url)
    }
    
    func handleIncomingVerificationURL(_ url: URL) {
        guard let email = EmailVerificationService.consumeVerificationURL(url) else { return }
        completeSessionAfterEmailVerification(normalizedEmail: email)
    }
    
    /// After the user opens the `bonacheter://verify` link (or pastes it).
    func completeSessionAfterEmailVerification(normalizedEmail: String) {
        guard LocalCredentialStore.accountExists(for: normalizedEmail) else { return }
        guard LocalCredentialStore.isEmailVerified(normalizedEmail) else { return }
        currentUserEmail = normalizedEmail
        phase = .main
        persist()
        NotificationCenter.default.post(name: .bonAcheterEmailVerified, object: nil)
    }
    
    /// Signs in with email/password stored in Keychain for this device.
    @discardableResult
    func signInWithEmail(email: String, password: String) -> EmailPasswordSignInResult {
        let em = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard LocalCredentialStore.verify(email: em, password: password) else { return .wrongCredentials }
        let norm = LocalCredentialStore.normalizedEmail(em)
        guard LocalCredentialStore.isEmailVerified(norm) else { return .emailNotVerified }
        currentUserEmail = norm
        phase = .main
        persist()
        return .success
    }
    
    /// Passkey sign-in after successful `ASAuthorization` (email must be verified).
    func signInWithPasskey(normalizedEmail: String) {
        let norm = LocalCredentialStore.normalizedEmail(normalizedEmail)
        guard LocalCredentialStore.accountExists(for: norm), LocalCredentialStore.isEmailVerified(norm) else { return }
        currentUserEmail = norm
        phase = .main
        persist()
    }
}
