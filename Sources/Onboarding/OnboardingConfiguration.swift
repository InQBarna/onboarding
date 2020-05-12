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

    var firstInstallWhatsNewJsonName: String = "WhatsNewCleanInstall"

    var onboardingTopImage: UIImage?

    var statusBarStyle: UIStatusBarStyle?

    func backgroundColor(forStep _: OnboardingStep) -> UIColor {
        return .blue
        #warning("TODO: ask someone about this")
    }

    func configureNavBar(_ navigationController: UINavigationController?) {
        #warning("TODO:")
        navigationController?.navigationBar.isTranslucent = false
    }

    func hidesNavigationBar(forStep step: OnboardingStep) -> Bool {
        switch step {
        case .blocking, .whatsNew:
            return false
        case .custom:
            #warning("Ask someone about this")
            return false
        }
    }

//    configuration.itemsView.imageSize = .original
//    configuration.itemsView.autoTintImage = true
//    configuration.completionButton.title = NSLocalizedString("Continúa", comment: "")
}
