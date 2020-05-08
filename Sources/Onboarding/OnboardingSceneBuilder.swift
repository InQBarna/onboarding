//
//  OnboardingSceneBuilder.swift
//  Mundo Deportivo
//
//  Created by Alexis on 18/11/2019.
//  Copyright © 2019 GrupoGodo. All rights reserved.
//

import Foundation
import WhatsNewKit

typealias PrimaryActionSelected = Bool

class OnboardingSceneBuilder {
    static func whatsNewVC(for whatsNew: WhatsNew, action: @escaping (() -> Void)) -> WhatsNewViewController? {

        GGAnalyticsManager.shared().trackPage(
            withScreenName: AnalyticsTagger.screenNameString(for: .onboardingWhatsNew),
            dataLayer: [:])

        return WhatsNewViewController(
            whatsNew: whatsNew,
            configuration: defaultCustomizedConfiguration(action),
            versionStore: WhatsNewVersionUserDefaultsStore())
    }

    static func activatePushInfoVC(action: @escaping ((PrimaryActionSelected) -> Void)) -> WhatsNewViewController {

        let completionButtonTitle = "Configurar Alertas"
        let items: [WhatsNew.Item] = [WhatsNew.Item(
            title: "Activa",
            subtitle: "Selecciona las secciones y autores sobre los que quieres recibir notificaciones",
            image: nil)]

        let pushInfo = WhatsNew(
            title: "Alertas",
            items: items)

        var configuration = defaultCustomizedConfiguration {
            action(true)
        }

        configuration.completionButton.title = completionButtonTitle

        return WhatsNewViewController(
            whatsNew: pushInfo,
            configuration: configuration)
    }

    static func loginBenefitsVC(blocking: Bool, action: @escaping ((LoginBenefitsAction) -> Void)) -> LoginBenefitsViewController {
        let story = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let loginBenefitsVC = story.instantiateViewController(withIdentifier: "LoginBenefitsVC") as? LoginBenefitsViewController else {
            assertionFailure("Should be able to load from storyboard")
            return LoginBenefitsViewController()
        }

        loginBenefitsVC.isBlocking = blocking
        loginBenefitsVC.action = action
        
        return loginBenefitsVC
    }

    static func blockingVersionVC() -> WhatsNewViewController {
        let appVersion = Bundle.main.currentAppVersion ?? "-"
        let minVersion = GGSettingsManager.shared().minIOSVersion()

        let message = String(format: NSLocalizedString("La versión de la aplicación %@ ya no está soportada. Por favor, actualiza a la versión %@ o superior.", comment: "") , arguments: [appVersion, minVersion])

        let info = WhatsNew(
            title: NSLocalizedString("Actualización recomendada", comment: ""),
            items: [
                WhatsNew.Item(
                    title: "",
                    subtitle: message,
                    image: nil)
        ])

        var configuration = defaultCustomizedConfiguration {
            OnboardingSceneBuilder.launchAppStore()
        }
        configuration.completionButton.title = NSLocalizedString("Actualizar", comment: "")

        return WhatsNewViewController(
            whatsNew: info,
            configuration: configuration)
    }

    static func launchAppStore() {
        guard let appStoreURL = URL(string: Customization.flavor().appStoreAppURLString()) else {
            assertionFailure()
            return
        }
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

    static func defaultCustomizedConfiguration(_ action: @escaping (() -> Void)) -> WhatsNewViewController.Configuration {
        var configuration = WhatsNewViewController.Configuration()

        let myTheme = WhatsNewViewController.Theme { configuration in
            configuration.backgroundColor = Customization.flavor().onboardingBackgroundColor()
            configuration.titleView.titleColor = Customization.flavor().onboardingTitleColor()
            configuration.titleView.titleFont = Customization.flavor().onboardingTitleFont()

            configuration.itemsView.titleFont = Customization.flavor().primaryOnboardingFont()
            configuration.itemsView.titleColor = Customization.flavor().onboardingPrimaryTextColor()
            configuration.itemsView.subtitleFont = Customization.flavor().secondaryOnboardingFont()
            configuration.itemsView.subtitleColor = Customization.flavor().onboardingSecondaryTextColor()
            configuration.itemsView.imageSize = .original
            configuration.itemsView.autoTintImage = true

            configuration.completionButton.backgroundColor = Customization.flavor().onboardingCompletionButtonBackgroundColor()
            configuration.completionButton.titleColor = Customization.flavor().onboardingCompletionButtonTitleColor()
            configuration.completionButton.titleFont = Customization.flavor().primaryOnboardingFont()
            configuration.completionButton.insets = UIEdgeInsets(top: 5, left: 23.5, bottom: 11.5, right: 23.5)
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
