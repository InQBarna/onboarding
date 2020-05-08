//
//  LoginBenefitsViewController.swift
//  LaVanguardia
//
//  Created by Alexis on 19/02/2020.
//  Copyright © 2020 GrupoGodo. All rights reserved.
//

import UIKit

enum LoginBenefitsAction {
    case goToRegister
    case goToLogin
    case remindLater
}

class LoginBenefitsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var remindLaterButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var action: ((LoginBenefitsAction) -> Void)?
    var isBlocking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        GGAnalyticsManager.shared().trackPage(
            withScreenName: AnalyticsTagger.screenNameString(for: .onboardingLoginBenefits),
            dataLayer: [:])
        
        OnboardingAnimation.animateSlidingUp([titleLabel, subtitleLabel, continueButton, remindLaterButton, loginButton])
    }

    private func setupView() {
        view.backgroundColor = UIColor.magicPotion()

        continueButton.layer.cornerRadius = 5

        titleLabel.text = NSLocalizedString("Bienvenido\na la nueva app", comment: "")
        subtitleLabel.text = NSLocalizedString("Regístrate gratis para seguir leyendo sin límites nuestro contenido", comment: "")

        continueButton.setTitle(NSLocalizedString("Continúa", comment: "").uppercased(), for: .normal)
        remindLaterButton.setTitle(NSLocalizedString("Recuérdamelo más tarde", comment: ""), for: .normal)
        loginButton.setTitle(NSLocalizedString("Ya estoy registrado en la web", comment: ""), for: .normal)

        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        remindLaterButton.addTarget(self, action: #selector(remindButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        remindLaterButton.isHidden = isBlocking

        imageView.image = Customization.flavor().onboardingTopImage()

        [titleLabel, subtitleLabel, continueButton, remindLaterButton, loginButton].forEach {
            $0.alpha = 0.0
        }
    }

    @objc func continueButtonTapped() {
        if let action = action {
            action(.goToRegister)

            GGAnalyticsManager.shared().trackEvent(
                withCategory: AnalyticsTagger.categoryString(for: .signwall),
                action: AnalyticsTagger.actionString(for: .next),
                label: AnalyticsTagger.labelString(for: .register),
                value: nil)
        }
    }

    @objc func remindButtonTapped() {
        if let action = action {
            action(.remindLater)
        }
    }

    @objc func loginButtonTapped() {
        if let action = action {
            action(.goToLogin)

            GGAnalyticsManager.shared().trackEvent(
                withCategory: AnalyticsTagger.categoryString(for: .signwall),
                action: AnalyticsTagger.actionString(for: .next),
                label: AnalyticsTagger.labelString(for: .login),
                value: nil)

        }
    }

}
