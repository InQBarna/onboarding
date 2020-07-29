//
//  OnboardingStartupValues.swift
//
//
//  Created by Alexis on 08/05/2020.
//

import Foundation

@objc public class StartupValues: NSObject {
    struct Constants {
        static let hasInstalledApp = "com.inqbarna.onboarding.appIsInstalled"
    }

    public static func isCleanInstall() -> Bool {
        return !UserDefaults.standard.bool(forKey: Constants.hasInstalledApp)
    }

    static func setAsInstalled() {
        UserDefaults.standard.set(true, forKey: Constants.hasInstalledApp)
    }
}
