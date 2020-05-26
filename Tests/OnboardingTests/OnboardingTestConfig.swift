//
//  File.swift
//  
//
//  Created by Alexis on 12/05/2020.
//
@testable import Onboarding
import UIKit

class OnboardingTestConfigSpy: OnboardingConfiguration {
    var titleColor: UIColor {
        titleColorCalled = true
        return .white
    }
    var titleFont: UIFont {
        titleFontCalled = true
        return UIFont.systemFont(ofSize: 24)
    }
    var primaryFont: UIFont {
        primaryFontCalled = true
        return UIFont.systemFont(ofSize: 26)
    }
    var primaryTextColor: UIColor {
        primaryTextColorCalled = true
        return .white
    }
    var secondaryFont: UIFont {
        secondaryFontCalled = true
        return UIFont.systemFont(ofSize: 16)
    }
    var secondaryTextColor: UIColor {
        secondaryTextColorCalled = true
        return .gray
    }
    var completionButtonBackgroundColor: UIColor {
        completionButtonBackgroundColorCalled = true
        return .brown
    }
    var completionButtonTitleColor: UIColor {
        completionButtonTitleColorCalled = true
        return .white
    }
    var completionButtonTitleFont: UIFont {
        completionButtonTitleFontCalled = true
        return UIFont.systemFont(ofSize: 20)
    }
    var completionButtonInsets: UIEdgeInsets {
        completionButtonInsetsCalled = true
        return .zero
    }
    var firstInstallWhatsNewJsonName: String {
        firstInstallWhatsNewJsonNameCalled = true
        return "testJson"
    }
    var onboardingTopImage: UIImage? {
        onboardingTopImageCalled = true
        return nil
    }
    var statusBarStyle: UIStatusBarStyle? {
        statusBarStyleCalled = true
        return .default
    }

    func backgroundColor(forStep: OnboardingStep) -> UIColor {
        backgroundColorForStepCalled = true
        return .black
    }

    func configureNavBar(_ viewController: UIViewController?) {
        configureNavBarCalled = true
    }

    func hidesNavigationBar(forStep step: OnboardingStep) -> Bool {
        hidesNavBarCalled = true
        return false
    }

    func blockingVersionString(withCurrentVersion: String, minVersion: String) -> String {
        blockingStringCalled = true
        return "-"
    }

    func recommendedUpdateTitle() -> String {
        recommendedUpdateStringCalled = true
        return "-"
    }

    func updateButtontTitle() -> String {
        updateButtonStringCalled = true
        return "-"
    }

    func continueButtonTitle() -> String {
        continueButtonStringCalled = true
        return "-"
    }

    var backgroundColorForStepCalled = false
    var configureNavBarCalled = false
    var hidesNavBarCalled = false
    var titleColorCalled = false
    var titleFontCalled = false
    var primaryFontCalled = false
    var primaryTextColorCalled = false
    var secondaryFontCalled = false
    var secondaryTextColorCalled = false
    var completionButtonBackgroundColorCalled = false
    var completionButtonTitleColorCalled = false
    var completionButtonTitleFontCalled = false
    var completionButtonInsetsCalled = false
    var firstInstallWhatsNewJsonNameCalled = false
    var onboardingTopImageCalled = false
    var statusBarStyleCalled = false
    var blockingStringCalled = false
    var recommendedUpdateStringCalled = false
    var updateButtonStringCalled = false
    var continueButtonStringCalled = false
}
