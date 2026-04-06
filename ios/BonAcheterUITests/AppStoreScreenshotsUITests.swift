//
//  AppStoreScreenshotsUITests.swift
//  BonAcheterUITests
//
//  Gera PNGs para a página do App Store Connect (correr com capture-app-store-screenshots.sh).
//

import XCTest

private enum ID {
    static let landingStart = "ui.landing.start"
    static let langFrench = "ui.onboarding.lang.french"
    static let householdCreate = "ui.onboarding.household.create"
    static let regionContinue = "ui.onboarding.region.continue"
    static let listAddItem = "ui.list.addItem"
}

final class AppStoreScreenshotsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTestReset"]
        app.launchArguments += ["-AppleLanguages", "(fr-CA)"]
        app.launchArguments += ["-AppleLocale", "fr_CA"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// UI tests run inside the simulator; `NSTemporaryDirectory()` is not the Mac. Prefer host path.
    private var screenshotOutputDirectory: URL {
        let env = ProcessInfo.processInfo.environment["APP_STORE_SCREENSHOT_DIR"] ?? ""
        if !env.isEmpty {
            return URL(fileURLWithPath: env, isDirectory: true)
        }
        if let host = ProcessInfo.processInfo.environment["SIMULATOR_HOST_HOME"], !host.isEmpty {
            return URL(fileURLWithPath: host)
                .appendingPathComponent("BonAcheterAppStoreScreenshots", isDirectory: true)
        }
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    private func writeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let data = screenshot.pngRepresentation
        let dir = screenshotOutputDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("\(name).png", isDirectory: false)
        do {
            try data.write(to: url)
            print("APP_STORE_SCREENSHOT wrote \(url.path)")
        } catch {
            XCTFail("Write failed \(url.path): \(error)")
        }
    }

    private func pause() {
        if ProcessInfo.processInfo.environment["UI_TEST_DEMO_PACING"] == "1" {
            Thread.sleep(forTimeInterval: 0.8)
        }
    }

    func testCaptureAppStoreScreenshots() throws {
        app.launch()
        writeScreenshot(named: "01-landing")

        XCTAssertTrue(app.buttons[ID.landingStart].waitForExistence(timeout: 10))
        app.buttons[ID.landingStart].tap()
        pause()
        writeScreenshot(named: "02-language")

        XCTAssertTrue(app.buttons[ID.langFrench].waitForExistence(timeout: 8))
        app.buttons[ID.langFrench].tap()
        pause()
        writeScreenshot(named: "03-household")

        XCTAssertTrue(app.buttons[ID.householdCreate].waitForExistence(timeout: 8))
        app.buttons[ID.householdCreate].tap()
        pause()
        writeScreenshot(named: "04-region")

        XCTAssertTrue(app.buttons[ID.regionContinue].waitForExistence(timeout: 8))
        app.buttons[ID.regionContinue].tap()
        pause()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 12))
        writeScreenshot(named: "05-dashboard")

        let listTab = app.tabBars.firstMatch.buttons.element(boundBy: 1)
        XCTAssertTrue(listTab.waitForExistence(timeout: 5))
        listTab.tap()
        pause()
        writeScreenshot(named: "06-list")

        let addItem = app.descendants(matching: .any).matching(identifier: ID.listAddItem).element
        XCTAssertTrue(addItem.waitForExistence(timeout: 8))
        addItem.tap()
        pause()
        writeScreenshot(named: "07-add-item")
    }
}
