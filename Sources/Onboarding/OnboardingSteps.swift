//
//  OnboardingSteps.swift
//  Mundo Deportivo
//
//  Created by Alexis on 15/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import Foundation
import WhatsNewKit

enum OnboardingStep: Int, CaseIterable {
    case blocking
    case login
    case whatsNew
    case push

    struct FileConstants {
        static let onboardingStoryName = "Onboarding"
        static let whatsNewFileName = "WhatsNew"
        static let whatsNewFileExtension = "json"
    }

    func shouldDisplay(completion: @escaping ((Bool) -> Void)) {
        switch self {
        case .blocking:
            completion(shouldBlockAppVersion())
        case .whatsNew:
            completion(shouldDisplayWhatsNew())
        case .push:
            shouldDisplayAlerts(completion)
        case .login:
            shouldDisplayLogin { (should) in
                completion(should)
            }
        }
    }

    func forcesOnboardDisplay() -> Bool {
        switch self {
        case .login, .whatsNew, .blocking:
            return true
        case .push:
            return false
        }
    }

    func viewController(action: @escaping ((OnboardingStep, Any) -> Void)) -> UIViewController? {
        switch self {
        case .blocking:
            return OnboardingSceneBuilder.blockingVersionVC() //No action to respond to here..
        case .whatsNew:
            if let whatsNew = whatsNewForCurrentVersion() {
                return OnboardingSceneBuilder.whatsNewVC(for: whatsNew) {
                    StartupValues.setAsInstalled()
                    action(self, true)
                }
            }
        case .push:
            return OnboardingSceneBuilder.activatePushInfoVC() { accepted in
                action(self, accepted)
            }
        case .login:
            let isLoginBlocking = Customization.flavor().isOnboardingLoginBlocking()
            return OnboardingSceneBuilder.loginBenefitsVC(blocking: isLoginBlocking) { accepted in
                action(self, accepted)
            }
        }

        assertionFailure("should have treated this already")
        return UIViewController()
    }

    func viewBackgroundColor() -> UIColor {
        switch self {
        case .login:
            return UIColor.magicPotion()
        case .blocking, .whatsNew, .push:
            return UIColor.white
        }
    }

    func hidesNavigationBar() -> Bool {
        switch self {
        case .login:
            return true
        case .blocking, .whatsNew, .push:
            return false
        }
    }

    private func shouldDisplayWhatsNew() -> Bool {
        return isCleanInstall() || hasUpdatedNonPatchVersion()
    }

    private func hasUpdatedNonPatchVersion() -> Bool {
        return whatsNewForCurrentVersion() != nil && !hasDisplayedWhatsNewForCurrentVersion()
    }

    private func isCleanInstall() -> Bool {
        return StartupValues.isCleanInstall()
    }

    private func whatsNewForCurrentVersion() -> WhatsNew? {
        let version = WhatsNew.Version.current()
        let versionString = version.description
        let isFreshInstall = StartupValues.isCleanInstall()

        var fileName = FileConstants.whatsNewFileName + versionString
        if isFreshInstall {
            fileName = Customization.flavor().firstInstallWhatsNewJsonName()
        }

        var whatsNewWithImageString: WhatsNewWithImageStrings?
        if let path = Bundle.main.path(forResource: fileName, ofType: FileConstants.whatsNewFileExtension) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: []),
                let decoded = try? JSONDecoder().decode(WhatsNewWithImageStrings.self, from: data) {
                whatsNewWithImageString = decoded
            }
        }

        var whatsNew = whatsNewWithImageString?.toWhatsNew()

        //pass correct version if it's a clean install - so it is marked as already seen by WhatsNewKit
        if isFreshInstall,
            let title = whatsNew?.title,
            let items = whatsNew?.items {
            whatsNew = WhatsNew(
                version: version,
                title: title,
                items: items)
        }

        return whatsNew
    }

    private func hasDisplayedWhatsNewForCurrentVersion() -> Bool {
        let version = WhatsNew.Version.current()
        return WhatsNewVersionUserDefaultsStore().has(version: version)
    }

    private func shouldDisplayAlerts(_ completion: @escaping ((Bool) -> Void)) {
        guard Customization.flavor().shouldRegisterForPush() else {
            completion(false)
            return
        }

        completion(!StartupValues.hasVisitedAlertsVC())
    }

    private func shouldDisplayLogin(completion: @escaping ((Bool) -> Void))  {
        Customization.flavor().shouldDisplayLogin { (should) in
            completion(should)
        }
    }

    private func shouldBlockAppVersion() -> Bool {
        guard let appVersion = Bundle.main.currentAppVersion else {
            return false
        }
        let minVersion = GGSettingsManager.shared().minIOSVersion()
        return appVersion.compare(minVersion, options: .numeric) == .orderedAscending
    }
}

extension Bundle {
    var currentAppVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
