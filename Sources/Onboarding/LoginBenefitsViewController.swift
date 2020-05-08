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
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var remindLaterButton: UIButton!
    @IBOutlet var imageView: UIImageView!

    var action: ((LoginBenefitsAction) -> Void)?
    var isBlocking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #warning("TODO: Recover call? Or at least create some handler for it")
//        GGAnalyticsManager.shared().trackPage(
//            withScreenName: AnalyticsTagger.screenNameString(for: .onboardingLoginBenefits),
//            dataLayer: [:])

        OnboardingAnimation.animateSlidingUp([titleLabel, subtitleLabel, continueButton, remindLaterButton, loginButton])
    }

    private func setupView() {
        view.backgroundColor = OnboardingConfiguration().backgroundColor(forStep: .login)

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

        imageView.image = OnboardingConfiguration().onboardingTopImage

        [titleLabel, subtitleLabel, continueButton, remindLaterButton, loginButton].forEach {
            $0.alpha = 0.0
        }
    }

    @objc func continueButtonTapped() {
        if let action = action {
            action(.goToRegister)

            #warning("TODO: Recover call? Or at least create some handler for it")
//            GGAnalyticsManager.shared().trackEvent(
//                withCategory: AnalyticsTagger.categoryString(for: .signwall),
//                action: AnalyticsTagger.actionString(for: .next),
//                label: AnalyticsTagger.labelString(for: .register),
//                value: nil)
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

            #warning("TODO: Recover call? Or at least create some handler for it")
//            GGAnalyticsManager.shared().trackEvent(
//                withCategory: AnalyticsTagger.categoryString(for: .signwall),
//                action: AnalyticsTagger.actionString(for: .next),
//                label: AnalyticsTagger.labelString(for: .login),
//                value: nil)
        }
    }
}
