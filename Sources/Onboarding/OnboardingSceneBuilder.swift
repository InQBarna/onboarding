//
//  OnboardingSceneBuilder.swift
//  Mundo Deportivo
//
//  Created by Alexis on 18/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import UIKit
import WhatsNewKit

typealias PrimaryActionSelected = Bool

class OnboardingSceneBuilder {
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

    static func activatePushInfoVC(action: @escaping ((PrimaryActionSelected) -> Void)) -> WhatsNewViewController {
        #warning("TODO: Make this external and agnostic.. just asking for default screen customization?!")
        let completionButtonTitle = "Configurar Alertas"
        let items: [WhatsNew.Item] = [WhatsNew.Item(
            title: "Activa",
            subtitle: "Selecciona las secciones y autores sobre los que quieres recibir notificaciones",
            image: nil
        )]

        let pushInfo = WhatsNew(
            title: "Alertas",
            items: items
        )

        var configuration = defaultCustomizedConfiguration {
            action(true)
        }

        configuration.completionButton.title = completionButtonTitle

        return WhatsNewViewController(
            whatsNew: pushInfo,
            configuration: configuration
        )
    }

    static func blockingVersionVC() -> WhatsNewViewController {
        let appVersion = Bundle.main.currentAppVersion ?? "-"

        #warning("TODO: Make this external")
        let minVersion = OnboardingConfiguration().minVersion

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
            OnboardingSceneBuilder.launchAppStore()
        }
        configuration.completionButton.title = NSLocalizedString("Actualizar", comment: "")

        return WhatsNewViewController(
            whatsNew: info,
            configuration: configuration
        )
    }

    static func launchAppStore() {
        #warning("TODO: Make this external")
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/es/app/id364587804") else {
            assertionFailure()
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

    static func defaultCustomizedConfiguration(_ action: @escaping (() -> Void)) -> WhatsNewViewController.Configuration {
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
