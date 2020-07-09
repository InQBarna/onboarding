//
//  OnboardingSceneBuilder.swift
//  Mundo Deportivo
//
//  Created by Alexis on 18/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import UIKit
import WhatsNewKit

public typealias PrimaryActionSelected = Bool
public typealias OnboardingViewController = WhatsNewViewController

public class OnboardingSceneBuilder {
    static func whatsNewVC(for whatsNew: WhatsNew, config: OnboardingConfiguration, action: @escaping (() -> Void)) -> WhatsNewViewController? {
        return WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: defaultCustomizedConfiguration(config: config, action),
            versionStore: WhatsNewVersionUserDefaultsStore()
        )
    }

    static func blockingVersionVC(_ minVersion: String, config: OnboardingConfiguration, appStoreUrlString: String) -> WhatsNewViewController {
        let appVersion = Bundle.main.currentAppVersion ?? "-"

        let message = config.blockingVersionString(withCurrentVersion: appVersion, minVersion: minVersion)

        let info = WhatsNew(
            title: config.recommendedUpdateTitle(),
            items: [
                WhatsNew.Item(
                    title: "",
                    subtitle: message,
                    image: nil
                )
            ]
        )

        var configuration = defaultCustomizedConfiguration(config: config) {
            OnboardingSceneBuilder.launchAppStore(appStoreUrlString)
        }
        configuration.completionButton.title = config.updateButtontTitle()

        return WhatsNewViewController(
            whatsNew: info,
            configuration: configuration
        )
    }

    static func launchAppStore(_ appStoreUrlString: String) {
        guard let appStoreURL = URL(string: appStoreUrlString) else {
            assertionFailure()
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

    public static func defaultCustomizedConfiguration(config: OnboardingConfiguration, _ action: @escaping (() -> Void)) -> WhatsNewViewController.Configuration {
        var configuration = WhatsNewViewController.Configuration()

        let myTheme = WhatsNewViewController.Theme { configuration in
//            configuration.backgroundColor = config.backgroundColor
            configuration.titleView.titleColor = config.titleColor
            configuration.titleView.titleFont = config.titleFont

            configuration.itemsView.titleFont = config.primaryFont
            configuration.itemsView.titleColor = config.primaryTextColor
            configuration.itemsView.subtitleFont = config.secondaryFont
            configuration.itemsView.subtitleColor = config.secondaryTextColor
            configuration.itemsView.imageSize = .original
            configuration.itemsView.autoTintImage = true

            configuration.completionButton.backgroundColor = config.completionButtonBackgroundColor
            configuration.completionButton.titleColor = config.completionButtonTitleColor
            configuration.completionButton.titleFont = config.completionButtonTitleFont
            configuration.completionButton.insets = config.completionButtonInsets
            configuration.completionButton.title = config.continueButtonTitle()
        }

        configuration.apply(theme: myTheme)
        configuration.apply(animation: .slideUp)

        configuration.completionButton.action = .custom(action: { _ in
            action()
        })

        return configuration
    }
}
