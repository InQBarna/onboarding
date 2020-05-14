//
//  OnboardingConfiguration.swift
//
//
//  Created by Alexis on 08/05/2020.
//

import UIKit

public protocol OnboardingConfiguration {
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
    var primaryFont: UIFont { get }
    var primaryTextColor: UIColor { get }
    var secondaryFont: UIFont { get }
    var secondaryTextColor: UIColor { get }
    var completionButtonBackgroundColor: UIColor { get }
    var completionButtonTitleColor: UIColor { get }
    var completionButtonTitleFont: UIFont { get }
    var completionButtonInsets: UIEdgeInsets { get }
    var firstInstallWhatsNewJsonName: String { get }
    var onboardingTopImage: UIImage? { get }
    var statusBarStyle: UIStatusBarStyle?  { get }

    func backgroundColor(forStep: OnboardingStep) -> UIColor
    func configureNavBar(_ viewController: UIViewController?)
    func hidesNavigationBar(forStep step: OnboardingStep) -> Bool
}
