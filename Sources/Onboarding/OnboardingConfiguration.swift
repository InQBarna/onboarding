//
//  OnboardingConfiguration.swift
//
//
//  Created by Alexis on 08/05/2020.
//

import UIKit

struct OnboardingConfiguration {
    var backgroundColor: UIColor = .white
    var titleColor: UIColor = .black
    var titleFont: UIFont = UIFont.boldSystemFont(ofSize: 28)
    var primaryFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    var primaryTextColor: UIColor = .black
    var secondaryFont: UIFont = UIFont.systemFont(ofSize: 18)
    var secondaryTextColor: UIColor = .black
    var completionButtonBackgroundColor: UIColor = .black
    var completionButtonTitleColor: UIColor = .white
    var completionButtonTitleFont: UIFont = UIFont.systemFont(ofSize: 20)
    var completionButtonInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

    var shouldRegisterForPush: Bool = true
    var shouldDisplayLogin: Bool = true
    var isOnboardingLoginBlocking: Bool = false
    var firstInstallWhatsNewJsonName: String = "WhatsNewCleanInstall"

    var minVersion: String = "1.0.0"

    var onboardingTopImage: UIImage?

    var statusBarStyle: UIStatusBarStyle?

    func backgroundColor(forStep _: OnboardingStep) -> UIColor {
        return .blue
        /*
         switch self {
         case .login:
             return UIColor.magicPotion()
         case .blocking, .whatsNew, .push:
             return UIColor.white
         }
         */
    }

    func configureNavBar() {
        #warning("TODO:")
    }

    func customViewController(forStep step: OnboardingStep, action: @escaping ((OnboardingStep, Any) -> Void)) -> UIViewController? {
        return nil
    }

//    configuration.itemsView.imageSize = .original
//    configuration.itemsView.autoTintImage = true
//    configuration.completionButton.title = NSLocalizedString("Continúa", comment: "")
}
