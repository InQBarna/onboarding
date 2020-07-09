//
//  OnboardingNavigationController.swift
//  Onboarding
//
//  Created by Alexis on 09/07/2020.
//

import UIKit

class OnboardingNavigationController: UINavigationController {
    private var statusBarStyle: UIStatusBarStyle

    init(rootViewController: UIViewController, statusBarStyle: UIStatusBarStyle) {
        self.statusBarStyle = statusBarStyle
        super.init(rootViewController: rootViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
