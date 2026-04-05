//
//  UIAccessibilityID.swift
//  BonAcheter
//
//  Stable identifiers for XCUITest / VoiceOver automation.
//

enum UIAccessibilityID {
    static let landingStart = "ui.landing.start"
    static let landingHaveAccount = "ui.landing.haveAccount"
    static let landingCreateAccount = "ui.landing.createAccount"
    
    static func onboardingLanguage(_ pref: AppLanguagePreference) -> String {
        "ui.onboarding.lang.\(pref.rawValue)"
    }
    
    static let onboardingBack = "ui.onboarding.back"
    
    static let householdCreate = "ui.onboarding.household.create"
    static let householdJoin = "ui.onboarding.household.join"
    static let householdInviteField = "ui.onboarding.household.inviteField"
    
    static let regionContinue = "ui.onboarding.region.continue"
    
    static let tabHome = "ui.tab.home"
    static let tabList = "ui.tab.list"
    
    static let listAddItem = "ui.list.addItem"
    static let listOpenSettings = "ui.list.settings"
    
    static let addItemNameField = "ui.addItem.name"
    static let addItemSave = "ui.addItem.save"
    
    static let loginSignIn = "ui.login.signIn"
    static let loginCancel = "ui.login.cancel"
    static let loginOpenSignUp = "ui.login.openSignUp"
    static let loginPasskey = "ui.login.passkey"
    
    static let signUpEmailField = "ui.signup.email"
    static let signUpPasswordField = "ui.signup.password"
    static let signUpConfirmField = "ui.signup.confirm"
    static let signUpSubmit = "ui.signup.submit"
    static let signUpCancel = "ui.signup.cancel"
    static let signUpOpenMail = "ui.signup.openMail"
    static let signUpPasteVerifyLink = "ui.signup.pasteVerifyLink"
}
