//
//  BonAcheterUITests.swift
//  BonAcheterUITests
//
//  Cenários de usabilidade (fluxos reais). Para acompanhar no ecrã: use o Simulador visível e
//  UI_TEST_DEMO_PACING=1 (ver run-ui-tests.sh).
//

import XCTest

/// Mirrors `UIAccessibilityID` in the app (UI test target cannot import the app module).
private enum TestID {
    static let landingStart = "ui.landing.start"
    static let landingHaveAccount = "ui.landing.haveAccount"
    static func onboardingLanguageEnglish() -> String { "ui.onboarding.lang.english" }
    static let householdCreate = "ui.onboarding.household.create"
    static let regionContinue = "ui.onboarding.region.continue"
    static let listAddItem = "ui.list.addItem"
    static let listOpenSettings = "ui.list.settings"
    static let addItemNameField = "ui.addItem.name"
    static let addItemSave = "ui.addItem.save"
    static let loginCancel = "ui.login.cancel"
}

final class BonAcheterUsabilityUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launchArguments += ["-AppleLocale", "en_CA"]
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    /// Pausa entre passos quando `UI_TEST_DEMO_PACING=1` — para ver o fluxo no Simulador.
    private func paceForViewer() {
        guard ProcessInfo.processInfo.environment["UI_TEST_DEMO_PACING"] == "1" else { return }
        Thread.sleep(forTimeInterval: 1.2)
    }
    
    private func completeOnboardingToMain() {
        XCTAssertTrue(app.buttons[TestID.landingStart].waitForExistence(timeout: 8))
        paceForViewer()
        app.buttons[TestID.landingStart].tap()
        paceForViewer()
        
        let english = app.buttons[TestID.onboardingLanguageEnglish()]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.tap()
        paceForViewer()
        
        let create = app.buttons[TestID.householdCreate]
        XCTAssertTrue(create.waitForExistence(timeout: 5))
        create.tap()
        paceForViewer()
        
        let regionContinue = app.buttons[TestID.regionContinue]
        XCTAssertTrue(regionContinue.waitForExistence(timeout: 5))
        regionContinue.tap()
        paceForViewer()
        
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8))
    }
    
    /// Do arranque ao separador Lista e abertura do ecrã de novo artigo.
    func testUsability_OnboardingThenAddItemFlow() throws {
        app.launch()
        completeOnboardingToMain()
        
        let listTab = app.tabBars.firstMatch.buttons["List"]
        XCTAssertTrue(listTab.waitForExistence(timeout: 5))
        listTab.tap()
        paceForViewer()
        
        let addLink = app.descendants(matching: .any).matching(identifier: TestID.listAddItem).element
        XCTAssertTrue(addLink.waitForExistence(timeout: 8))
        addLink.tap()
        paceForViewer()
        
        let nameField = app.descendants(matching: .any).matching(identifier: TestID.addItemNameField).element
        XCTAssertTrue(nameField.waitForExistence(timeout: 8))
        nameField.tap()
        nameField.typeText("UI Test Apples")
        paceForViewer()
        
        if app.keyboards.count > 0 {
            app.swipeDown(velocity: XCUIGestureVelocity.fast)
        }
        let saveBtn = app.descendants(matching: .any).matching(identifier: TestID.addItemSave).element
        XCTAssertTrue(saveBtn.waitForExistence(timeout: 5))
        saveBtn.tap()
        paceForViewer()
        
        let applesLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "UI Test Apples")).element
        XCTAssertTrue(applesLabel.waitForExistence(timeout: 8))
    }
    
    /// Landing → “já tenho conta” → fechar o sheet (descoberta do login).
    func testUsability_LoginSheetCanCancel() throws {
        app.launch()
        paceForViewer()
        app.buttons[TestID.landingHaveAccount].tap()
        paceForViewer()
        XCTAssertTrue(app.buttons[TestID.loginCancel].waitForExistence(timeout: 5))
        app.buttons[TestID.loginCancel].tap()
        paceForViewer()
        XCTAssertTrue(app.buttons[TestID.landingStart].waitForExistence(timeout: 5))
    }
    
    /// Após onboarding, abre Definições a partir da lista (engrenagem).
    func testUsability_OpenSettingsFromList() throws {
        app.launch()
        completeOnboardingToMain()
        
        app.tabBars.firstMatch.buttons["List"].tap()
        paceForViewer()
        
        let settingsBtn = app.buttons.matching(identifier: TestID.listOpenSettings).element(boundBy: 0)
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: 8))
        settingsBtn.tap()
        paceForViewer()
        
        XCTAssertTrue(app.staticTexts["Settings"].firstMatch.waitForExistence(timeout: 8))
    }
}
