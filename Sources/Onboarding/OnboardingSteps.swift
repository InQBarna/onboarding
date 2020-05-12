//
//  OnboardingSteps.swift
//  Mundo Deportivo
//
//  Created by Alexis on 15/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import UIKit
import WhatsNewKit

public enum OnboardingStep: Equatable {
    case blocking(minVersion: String, appStoreUrlString: String)
    case whatsNew
    case push
    ///provides the default (but customizable) WhatsNewKit design
    case defaultDesign(identifier: String)
    ///can prove whatever kind of design needed
    case customDesign(identifier: String)

    struct FileConstants {
        static let onboardingStoryName = "Onboarding"
        static let whatsNewFileName = "WhatsNew"
        static let whatsNewFileExtension = "json"
    }

    func shouldDisplay(completion: @escaping ((Bool) -> Void)) {
        switch self {
        case .blocking(let minVersion, _):
            completion(shouldBlockAppVersion(minVersion))
        case .whatsNew:
            completion(shouldDisplayWhatsNew())
        case .push:
            shouldDisplayAlerts(completion)
        case .defaultDesign(let identifier),
             .customDesign(let identifier):
            #warning("TODO: should ask some delegate or something")
            completion(true)
        }
    }

    func forcesOnboardDisplay() -> Bool {
        switch self {
        case .whatsNew, .blocking:
            return true
        case .push:
            return false
        case .customDesign(let identifier), .defaultDesign(let identifier):
            #warning("Ask someone about this")
            return true
        }
    }

    func viewController(action: @escaping ((OnboardingStep, Any) -> Void)) -> UIViewController? {
        switch self {
        case .blocking(let minVersion, let appStoreString):
            return OnboardingSceneBuilder.blockingVersionVC(minVersion, appStoreUrlString: appStoreString) // No action to respond to here..
        case .whatsNew:
            if let whatsNew = whatsNewForCurrentVersion() {
                return OnboardingSceneBuilder.whatsNewVC(for: whatsNew) {
                    StartupValues.setAsInstalled()
                    action(self, true)
                }
            }
        case .push:
            return OnboardingSceneBuilder.activatePushInfoVC { accepted in
                action(self, accepted)
            }
        default:
            return nil
        }

        assertionFailure("should have treated this already")
        return UIViewController()
    }

    func viewBackgroundColor() -> UIColor {
        return OnboardingConfiguration().backgroundColor(forStep: self)
    }

    func hidesNavigationBar() -> Bool {
        switch self {
        case .blocking, .whatsNew, .push:
            return false
        case .customDesign(let identifier), .defaultDesign(let identifier):
            #warning("Ask someone about this")
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
            fileName = OnboardingConfiguration().firstInstallWhatsNewJsonName
        }

        var whatsNewWithImageString: WhatsNewWithImageStrings?
        if let path = Bundle.main.path(forResource: fileName, ofType: FileConstants.whatsNewFileExtension) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: []),
                let decoded = try? JSONDecoder().decode(WhatsNewWithImageStrings.self, from: data) {
                whatsNewWithImageString = decoded
            }
        }

        var whatsNew = whatsNewWithImageString?.toWhatsNew()

        // pass correct version if it's a clean install - so it is marked as already seen by WhatsNewKit
        if isFreshInstall,
            let title = whatsNew?.title,
            let items = whatsNew?.items {
            whatsNew = WhatsNew(
                version: version,
                title: title,
                items: items
            )
        }

        return whatsNew
    }

    private func hasDisplayedWhatsNewForCurrentVersion() -> Bool {
        let version = WhatsNew.Version.current()
        return WhatsNewVersionUserDefaultsStore().has(version: version)
    }

    private func shouldDisplayAlerts(_ completion: @escaping ((Bool) -> Void)) {
        guard OnboardingConfiguration().shouldRegisterForPush else {
            completion(false)
            return
        }

        completion(!StartupValues.hasVisitedAlertsVC())
    }

    private func shouldBlockAppVersion(_ minVersion: String?) -> Bool {
        guard let appVersion = Bundle.main.currentAppVersion,
            let minVersion = minVersion else {
            return false
        }
        return appVersion.compare(minVersion, options: .numeric) == .orderedAscending
    }
}

extension Bundle {
    var currentAppVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
