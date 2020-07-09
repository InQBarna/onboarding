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
    case custom(identifier: String, vc: UIViewController)

    struct FileConstants {
        static let onboardingStoryName = "Onboarding"
        static let whatsNewFileName = "WhatsNew"
        static let whatsNewFileExtension = "json"
    }

    func shouldDisplay(config: OnboardingConfiguration, completion: @escaping ((Bool) -> Void)) {
        switch self {
        case let .blocking(minVersion, _):
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
        case let .blocking(minVersion, appStoreString):
            return OnboardingSceneBuilder.blockingVersionVC(minVersion, config: config, appStoreUrlString: appStoreString) // No action to respond to here..
        case .whatsNew:
            if let whatsNew = whatsNewForCurrentVersion(config: config) ?? pendingWhatsNewToDisplaySinceLastInstalled() {
                return OnboardingSceneBuilder.whatsNewVC(for: whatsNew, config: config) {
                    StartupValues.setAsInstalled()
                    action(self, true)
                }
            }
        case let .custom(_, vc):
            return vc
        }

        return UIViewController()
    }

    private func shouldDisplayWhatsNew(config: OnboardingConfiguration) -> Bool {
        return isCleanInstall()
            || hasUpdatedNonPatchVersionWithWhatsNewFile(config: config)
            || hasSomeWhatsNewPendingSinceLastInstalled()
    }

    private func hasUpdatedNonPatchVersionWithWhatsNewFile(config: OnboardingConfiguration) -> Bool {
        return whatsNewForCurrentVersion(config: config) != nil && !hasDisplayedWhatsNewForCurrentVersion()
    }

    private func hasSomeWhatsNewPendingSinceLastInstalled() -> Bool {
        return pendingWhatsNewToDisplaySinceLastInstalled() != nil
    }

    private func pendingWhatsNewToDisplaySinceLastInstalled() -> WhatsNew? {
        guard let lastWhatsNewDisplayed = WhatsNewVersionUserDefaultsStore().lastWhatsNewDisplayedVersion() else {
            // there should be something here - if not, that means we're coming from 6.x.x and this should be considered as a clean install
            return nil
        }

        return whatsNewFileInBetweenCurrent(andVersion: lastWhatsNewDisplayed)
    }

    private func whatsNewFileInBetweenCurrent(andVersion latestDisplayedWhatsNewVersion: WhatsNew.Version) -> WhatsNew? {
        let currentVersion = WhatsNew.Version.current()
        let majorVersion = currentVersion.major
        var oldestPossibleVersion = latestDisplayedWhatsNewVersion

        guard currentVersion != oldestPossibleVersion else {
            return nil
        }

        // only search for whatsNew files of the same major version
        if latestDisplayedWhatsNewVersion.major < majorVersion {
            oldestPossibleVersion = WhatsNew.Version(major: majorVersion, minor: 0, patch: 0)
        }

        var minor = currentVersion.minor
        var patch = currentVersion.patch

        while minor >= 0 {
            while patch >= 0 {
                let version = WhatsNew.Version(major: majorVersion, minor: minor, patch: patch)
                if let file = whatsNew(for: version) {
                    // found it - now change its version to the current one to mark it as displayed correctly
                    return WhatsNew(
                        version: WhatsNew.Version.current(),
                        title: file.title,
                        items: file.items
                    )
                } else if version == oldestPossibleVersion {
                    return nil
                } else {
                    patch -= 1
                }
            }

            minor -= 1
            patch = 9
        }

        return nil
    }

    private func isCleanInstall() -> Bool {
        return StartupValues.isCleanInstall()
    }

    private func whatsNewForCurrentVersion(config: OnboardingConfiguration) -> WhatsNew? {
        if StartupValues.isCleanInstall() {
            let fileName = config.firstInstallWhatsNewJsonName
            let whatsNewFile = whatsNew(for: fileName)

            // pass correct version if it's a clean install - so it is marked as already seen by WhatsNewKit
            if let title = whatsNewFile?.title,
                let items = whatsNewFile?.items {
                return WhatsNew(
                    version: WhatsNew.Version.current(),
                    title: title,
                    items: items
                )
            }
        } else {
            return whatsNew(for: WhatsNew.Version.current())
        }

        return nil
    }

    private func whatsNew(for version: WhatsNew.Version) -> WhatsNew? {
        let versionString = version.description
        let fileName = FileConstants.whatsNewFileName + versionString

        return whatsNew(for: fileName)
    }

    private func whatsNew(for fileName: String) -> WhatsNew? {
        var whatsNewWithImageString: WhatsNewWithImageStrings?
        if let path = Bundle.main.path(forResource: fileName, ofType: FileConstants.whatsNewFileExtension) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: []),
                let decoded = try? JSONDecoder().decode(WhatsNewWithImageStrings.self, from: data) {
                whatsNewWithImageString = decoded
            }
        }

        return whatsNewWithImageString?.toWhatsNew()
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
