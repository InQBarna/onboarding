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
    static func whatsNewVC(for whatsNew: WhatsNew, action: @escaping (() -> Void)) -> WhatsNewViewController? {
        #warning("TODO: Recover call? Or at least create some handler for it")
//        GGAnalyticsManager.shared().trackPage(
//            withScreenName: AnalyticsTagger.screenNameString(for: .onboardingWhatsNew),
//            dataLayer: [:])

        return WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: defaultCustomizedConfiguration(action),
            versionStore: WhatsNewVersionUserDefaultsStore()
        )
    }

    

    static func blockingVersionVC(_ minVersion: String, appStoreUrlString: String) -> WhatsNewViewController {
        let appVersion = Bundle.main.currentAppVersion ?? "-"

        let message = String(format: NSLocalizedString("La versión de la aplicación %@ ya no está soportada. Por favor, actualiza a la versión %@ o superior.", comment: ""), arguments: [appVersion, minVersion])

        let info = WhatsNew(
            title: NSLocalizedString("Actualización recomendada", comment: ""),
            items: [
                WhatsNew.Item(
                    title: "",
                    subtitle: message,
                    image: nil
                ),
            ]
        )

        var configuration = defaultCustomizedConfiguration {
            OnboardingSceneBuilder.launchAppStore(appStoreUrlString)
        }
        configuration.completionButton.title = NSLocalizedString("Actualizar", comment: "")

        return WhatsNewViewController(
            whatsNew: info,
            configuration: configuration
        )
    }

    static func launchAppStore(_  appStoreUrlString: String) {
        #warning("TODO: Make this external")
        guard let appStoreURL = URL(string: appStoreUrlString) else {
            assertionFailure()
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

    public static func defaultCustomizedConfiguration(_ action: @escaping (() -> Void)) -> WhatsNewViewController.Configuration {
        var configuration = WhatsNewViewController.Configuration()

        let myTheme = WhatsNewViewController.Theme { configuration in
            let onboardingConfig = OnboardingConfiguration()
            configuration.backgroundColor = onboardingConfig.backgroundColor
            configuration.titleView.titleColor = onboardingConfig.titleColor
            configuration.titleView.titleFont = onboardingConfig.titleFont

            configuration.itemsView.titleFont = onboardingConfig.primaryFont
            configuration.itemsView.titleColor = onboardingConfig.primaryTextColor
            configuration.itemsView.subtitleFont = onboardingConfig.secondaryFont
            configuration.itemsView.subtitleColor = onboardingConfig.secondaryTextColor
            configuration.itemsView.imageSize = .original
            configuration.itemsView.autoTintImage = true

            configuration.completionButton.backgroundColor = onboardingConfig.completionButtonBackgroundColor
            configuration.completionButton.titleColor = onboardingConfig.completionButtonTitleColor
            configuration.completionButton.titleFont = onboardingConfig.completionButtonTitleFont
            configuration.completionButton.insets = onboardingConfig.completionButtonInsets
            configuration.completionButton.title = NSLocalizedString("Continúa", comment: "")
        }

        configuration.apply(theme: myTheme)
        configuration.apply(animation: .slideUp)

        configuration.completionButton.action = .custom(action: { _ in
            action()
        })

        return configuration
    }
}
