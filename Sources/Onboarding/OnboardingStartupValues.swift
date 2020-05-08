//
//  OnboardingStartupValues.swift
//
//
//  Created by Alexis on 08/05/2020.
//

import Foundation

@objc class StartupValues: NSObject {
    struct Constants {
        static let hasVisitedAlertsVC = "com.inqbarna.onboarding.hasVisitedAlertsVC"
        static let hasVisitedLoginBenefitsVC = "com.inqbarna.onboarding.hasVisitedLoginBenefitsVC"
        static let hasInstalledApp = "com.inqbarna.onboarding.appIsInstalled"
    }

    static func hasVisitedAlertsVC() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.hasVisitedAlertsVC)
    }

    static func markAlertsVCAsVisited() {
        UserDefaults.standard.set(true, forKey: Constants.hasVisitedAlertsVC)
    }

    static func isCleanInstall() -> Bool {
        return !UserDefaults.standard.bool(forKey: Constants.hasInstalledApp)
    }

    static func setAsInstalled() {
        UserDefaults.standard.set(true, forKey: Constants.hasInstalledApp)
    }
}
