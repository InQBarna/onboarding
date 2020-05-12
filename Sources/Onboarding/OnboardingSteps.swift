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
    ///provides the default (but customizable) WhatsNewKit design
    case custom(identifier: String, vc: UIViewController)

    struct FileConstants {
        static let onboardingStoryName = "Onboarding"
        static let whatsNewFileName = "WhatsNew"
        static let whatsNewFileExtension = "json"
    }

    func shouldDisplay(config: OnboardingConfiguration, completion: @escaping ((Bool) -> Void)) {
        switch self {
        case .blocking(let minVersion, _):
            completion(shouldBlockAppVersion(minVersion))
        case .whatsNew:
            completion(shouldDisplayWhatsNew(config: config))
        case .custom:
            completion(true)
        }
    }

    func forcesOnboardDisplay() -> Bool {
        switch self {
        case .whatsNew, .blocking:
            return true
        case .custom:
            return true
        }
    }

    func viewController(config: OnboardingConfiguration, action: @escaping ((OnboardingStep, Any) -> Void)) -> UIViewController? {
        switch self {
        case .blocking(let minVersion, let appStoreString):
            return OnboardingSceneBuilder.blockingVersionVC(minVersion, config: config, appStoreUrlString: appStoreString) // No action to respond to here..
        case .whatsNew:
            if let whatsNew = whatsNewForCurrentVersion(config: config) {
                return OnboardingSceneBuilder.whatsNewVC(for: whatsNew, config: config) {
                    StartupValues.setAsInstalled()
                    action(self, true)
                }
            }
        case .custom(_, let vc):
            return vc
        }

        return UIViewController()
    }

    private func shouldDisplayWhatsNew(config: OnboardingConfiguration) -> Bool {
        return isCleanInstall() || hasUpdatedNonPatchVersion(config: config)
    }

    private func hasUpdatedNonPatchVersion(config: OnboardingConfiguration) -> Bool {
        return whatsNewForCurrentVersion(config: config) != nil && !hasDisplayedWhatsNewForCurrentVersion()
    }

    private func isCleanInstall() -> Bool {
        return StartupValues.isCleanInstall()
    }

    private func whatsNewForCurrentVersion(config: OnboardingConfiguration) -> WhatsNew? {
        let version = WhatsNew.Version.current()
        let versionString = version.description
        let isFreshInstall = StartupValues.isCleanInstall()

        var fileName = FileConstants.whatsNewFileName + versionString
        if isFreshInstall {
            fileName = config.firstInstallWhatsNewJsonName
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
