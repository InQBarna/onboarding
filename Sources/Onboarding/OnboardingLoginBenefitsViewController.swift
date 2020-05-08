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

class OnboardingLoginBenefitsViewController: UIViewController {
    struct Constants {
        static let stackViewPaddings = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        static let titleSubtitleSpacing: CGFloat = 10
        static let continueTopSpacing: CGFloat = 60
        static let continueBottomSpacing: CGFloat = 60
        static let imageHeight: CGFloat = 60
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = OnboardingConfiguration().primaryFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    lazy var titleSubtitleSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = OnboardingConfiguration().secondaryFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    lazy var continueTopSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var continueBottomSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()

    lazy var remindLaterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = OnboardingConfiguration().onboardingTopImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    var action: ((LoginBenefitsAction) -> Void)?
    var isBlocking: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
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

        view.addSubview(stackView)
        [titleLabel,
         titleSubtitleSpacer,
         subtitleLabel,
         continueTopSpacer,
         continueButton,
         continueBottomSpacer,
         remindLaterButton,
         loginButton,
         imageView].forEach({
            stackView.addArrangedSubview($0)
        })

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

        [titleLabel, subtitleLabel, continueButton, loginButton, remindLaterButton].forEach {
            $0.alpha = 0.0
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            titleSubtitleSpacer.heightAnchor.constraint(equalToConstant: Constants.titleSubtitleSpacing),
            continueTopSpacer.heightAnchor.constraint(equalToConstant: Constants.continueTopSpacing),
            continueBottomSpacer.heightAnchor.constraint(equalToConstant: Constants.continueBottomSpacing),

            imageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight)
        ])

        let leftPadding = stackView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: Constants.stackViewPaddings.left)
        leftPadding.priority = UILayoutPriority(999)
        leftPadding.isActive = true

        let rightPadding = stackView.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: -Constants.stackViewPaddings.right)
        rightPadding.priority = UILayoutPriority(999)
        rightPadding.isActive = true
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
