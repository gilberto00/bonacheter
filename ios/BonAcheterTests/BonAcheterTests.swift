//
//  BonAcheterTests.swift
//  BonAcheterTests
//

import XCTest
@testable import BonAcheter

final class ListItemCodableTests: XCTestCase {
    func testRoundTripWithBarcode() throws {
        let id = UUID()
        let item = ListItem(id: id, name: "Milk", quantity: "1", unit: "L", isTaxable: false, barcode: "3017620422003")
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(ListItem.self, from: data)
        XCTAssertEqual(decoded.id, id)
        XCTAssertEqual(decoded.name, "Milk")
        XCTAssertEqual(decoded.barcode, "3017620422003")
        XCTAssertFalse(decoded.isTaxable)
    }
    
    func testDecodesLegacyJSONWithoutBarcodeField() throws {
        let json = """
        {"id":"550E8400-E29B-41D4-A716-446655440000","name":"Pain","quantity":"1","unit":"piece","isTaxable":false}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let item = try JSONDecoder().decode(ListItem.self, from: data)
        XCTAssertNil(item.barcode)
        XCTAssertEqual(item.name, "Pain")
    }
}

final class OpenFoodFactsClientTests: XCTestCase {
    func testFetchRejectsShortBarcode() async throws {
        do {
            _ = try await OpenFoodFactsClient.shared.fetchProduct(barcode: "12", preferredLanguageCode: "en")
            XCTFail("Expected OpenFoodFactsError.invalidBarcode")
        } catch OpenFoodFactsError.invalidBarcode {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

final class AppStateBehaviorTests: XCTestCase {
    private let persistenceKey = "BonAcheter.persistedState"
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
        super.tearDown()
    }
    
    func testEnsureHouseholdCreatedGeneratesSixCharCode() {
        let state = AppState()
        XCTAssertNil(state.householdInviteCode)
        state.ensureHouseholdCreated()
        XCTAssertEqual(state.householdInviteCode?.count, 6)
        state.ensureHouseholdCreated()
        let first = state.householdInviteCode
        state.ensureHouseholdCreated()
        XCTAssertEqual(state.householdInviteCode, first)
    }
    
    func testJoinHouseholdNormalizesCode() {
        let state = AppState()
        state.joinHousehold(inviteCode: "ab-12 cd")
        XCTAssertEqual(state.householdInviteCode, "AB12CD")
    }
    
    func testJoinHouseholdIgnoresShortCode() {
        let state = AppState()
        state.joinHousehold(inviteCode: "a1")
        XCTAssertNil(state.householdInviteCode)
    }
    
    func testPriceStatsWhenEmpty() {
        let state = AppState()
        let stats = state.priceStats(for: UUID())
        XCTAssertEqual(stats.count, 0)
        XCTAssertNil(stats.average)
    }
    
    func testRegisterPurchaseAddsSpendAndHistory() throws {
        let state = AppState()
        let start = state.spentThisPeriod
        let itemId = state.listItems[0].id
        let entry = PriceHistoryEntry(listItemId: itemId, storeName: "IGA", unitPrice: 4.99)
        state.registerPurchase(total: 12.34, entries: [entry])
        XCTAssertEqual(state.spentThisPeriod, start + 12.34, accuracy: 0.001)
        XCTAssertEqual(state.priceStats(for: itemId).count, 1)
        let avg = try XCTUnwrap(state.priceStats(for: itemId).average)
        XCTAssertEqual(avg, 4.99, accuracy: 0.001)
    }
}

final class GroceryUnitCatalogTests: XCTestCase {
    func testMetricUnitsContainLiter() {
        let units = GroceryUnitCatalog.orderedUnitIds(for: .metricBrazilCanada)
        XCTAssertTrue(units.contains("L"))
        XCTAssertTrue(units.contains("piece"))
    }
    
    func testValidation() {
        XCTAssertTrue(GroceryUnitCatalog.isValid(unitId: "lb", system: .usCustomary))
        XCTAssertFalse(GroceryUnitCatalog.isValid(unitId: "lb", system: .metricBrazilCanada))
    }
}

final class AppLanguageResolverTests: XCTestCase {
    func testFixedFrench() {
        XCTAssertTrue(AppLanguageResolver.resolvedLanguageCode(for: .french).hasPrefix("fr"))
    }
    
    func testFixedEnglish() {
        XCTAssertTrue(AppLanguageResolver.resolvedLanguageCode(for: .english).hasPrefix("en"))
    }
}

final class LocalCredentialStoreTests: XCTestCase {
    override func tearDown() {
        LocalCredentialStore.wipeAll()
        super.tearDown()
    }
    
    func testEmailValidation() {
        XCTAssertTrue(LocalCredentialStore.isValidEmailFormat("a@b.co"))
        XCTAssertTrue(LocalCredentialStore.isValidEmailFormat(" User@Example.com "))
        XCTAssertFalse(LocalCredentialStore.isValidEmailFormat("not-an-email"))
        XCTAssertFalse(LocalCredentialStore.isValidEmailFormat("@nodomain.com"))
    }
    
    func testSaveAndVerify() throws {
        try LocalCredentialStore.saveAccount(email: "Test@Example.com", password: "password123")
        XCTAssertTrue(LocalCredentialStore.accountExists(for: "test@example.com"))
        XCTAssertTrue(LocalCredentialStore.verify(email: "test@example.com", password: "password123"))
        XCTAssertFalse(LocalCredentialStore.verify(email: "test@example.com", password: "wrong"))
    }
}

final class AppStateRegistrationTests: XCTestCase {
    private let persistenceKey = "BonAcheter.persistedState"
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: persistenceKey)
        LocalCredentialStore.wipeAll()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
        LocalCredentialStore.wipeAll()
        super.tearDown()
    }
    
    func testRegisterThenSignIn() {
        UserDefaults.standard.set(true, forKey: "BonAcheter.tests.skipEmailVerification")
        defer { UserDefaults.standard.removeObject(forKey: "BonAcheter.tests.skipEmailVerification") }
        let state = AppState()
        let r = state.registerAccount(email: "u@test.com", password: "abcdefgh", confirmPassword: "abcdefgh")
        XCTAssertEqual(r, .success)
        XCTAssertEqual(state.currentUserEmail, "u@test.com")
        XCTAssertEqual(state.phase, .main)
        
        state.phase = .landing
        state.currentUserEmail = nil
        XCTAssertEqual(state.signInWithEmail(email: "U@Test.Com", password: "abcdefgh"), .success)
        XCTAssertEqual(state.currentUserEmail, "u@test.com")
    }
    
    func testRegisterBlocksSignInUntilEmailVerified() {
        UserDefaults.standard.removeObject(forKey: "BonAcheter.tests.skipEmailVerification")
        let state = AppState()
        let r = state.registerAccount(email: "v@test.com", password: "12345678", confirmPassword: "12345678")
        guard case .pendingEmailVerification(let email, let url) = r else {
            XCTFail("Expected pending email verification")
            return
        }
        XCTAssertNil(state.currentUserEmail)
        XCTAssertEqual(state.phase, .landing)
        XCTAssertEqual(state.signInWithEmail(email: "v@test.com", password: "12345678"), .emailNotVerified)
        XCTAssertNotNil(EmailVerificationService.consumeVerificationURL(url))
        XCTAssertTrue(LocalCredentialStore.isEmailVerified(email))
        state.completeSessionAfterEmailVerification(normalizedEmail: email)
        XCTAssertEqual(state.currentUserEmail, email)
        XCTAssertEqual(state.phase, .main)
        state.phase = .landing
        state.currentUserEmail = nil
        XCTAssertEqual(state.signInWithEmail(email: "v@test.com", password: "12345678"), .success)
    }
    
    func testRegisterRejectsDuplicate() {
        let state = AppState()
        _ = state.registerAccount(email: "dup@test.com", password: "12345678", confirmPassword: "12345678")
        let r2 = state.registerAccount(email: "dup@test.com", password: "12345678", confirmPassword: "12345678")
        XCTAssertEqual(r2, .accountAlreadyExists)
    }
}

final class ListSyncServiceTests: XCTestCase {
    func testLocalOnlyServiceLifecycle() {
        let sync = LocalOnlyListSyncService()
        XCTAssertFalse(sync.isConnected)
        sync.start(householdId: "ABC123", onRemoteList: { _ in })
        sync.publishList([])
        sync.stop()
        XCTAssertFalse(sync.isConnected)
    }
}
