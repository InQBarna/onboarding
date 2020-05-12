import SafariServices
import UIKit
import WhatsNewKit

class OnboardingRootViewController: UIViewController {
    var steps = [OnboardingStep]()
    private var activeStep = 0
    private var wasRoutedToSettings = false

    struct Constants {
        static let containerPaddings = UIEdgeInsets(top: 25, left: 8, bottom: 0, right: 8)
        static let pageControlBottomPadding: CGFloat = 8
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    #warning("TODO: Recover")
//    private var authHandler: GGLVAuthPresentationHandler? //retain for the ASWebAuthenticationSession to work properly
//
//    lazy private var keychainHandler: CredentialsHandling = {
//        return LocksmithCredentialsHandler()
//    }()

    var onFinishOnboarding: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()

        displayActiveStep()

        addObservers()
    }

    deinit {
        removeObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OnboardingConfiguration().statusBarStyle ?? .default
    }

    private func setupView() {
        view.backgroundColor = OnboardingConfiguration().backgroundColor

        [pageControl, containerView].forEach {
            view.addSubview($0)
        }

        pageControl.numberOfPages = steps.count
        pageControl.currentPage = activeStep

        OnboardingConfiguration().configureNavBar(navigationController)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.containerPaddings.left),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.containerPaddings.top),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.containerPaddings.right),
            containerView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: Constants.containerPaddings.bottom),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        if #available(iOS 11.0, *) {
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.pageControlBottomPadding).isActive = true
        } else {
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants.pageControlBottomPadding).isActive = true
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        #warning("TODO: Recover")
        /*
             NotificationCenter.default.addObserver(
                 self,
                 selector: #selector(authStatusChanged(_:)),
                 name: NSNotification.Name(rawValue: kUserAuthStatusChanged),
                 object: nil)
         */
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func didBecomeActive() {
        let step = steps[activeStep]
        switch step {
        case .whatsNew, .blocking:
            break
        case .push:
            if wasRoutedToSettings {
                moveToNextStep()
            }
        case .customDesign(let identifier), .defaultDesign(let identifier):
            #warning("forward this to someone")
            break
        }

        wasRoutedToSettings = false
    }

    private func displayActiveStep() {
        if let firstVC = makeViewController(at: activeStep) {
            view.backgroundColor = steps[activeStep].viewBackgroundColor()
            navigationController?.setNavigationBarHidden(steps[activeStep].hidesNavigationBar(), animated: false)

            displayVC(firstVC)
        } else {
            finishOnboarding()
        }
    }

    private func displayVC(_ vc: UIViewController) {
        removeDisplayedVC()

        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }

    private func removeDisplayedVC() {
        if let childVC = children.first {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
    }

    private func moveToNextStep() {
        if activeStep + 1 < steps.count {
            activeStep += 1
            displayActiveStep()
            pageControl.currentPage = activeStep
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        if let finishClosure = onFinishOnboarding {
            finishClosure()
        }
    }

    private func makeViewController(at index: Int) -> UIViewController? {
        let step = steps[index]

        #warning("TODO: How could we change this Any to some concrete type? ")
        let action: ((OnboardingStep, Any) -> Void) = { (step, response) in
            switch step {
            case .whatsNew:
                #warning("TODO: Recover call? Or at least create some handler for it")
                //                GGAnalyticsManager.shared()?.trackEvent(
                //                    withCategory: AnalyticsTagger.categoryString(for: .navigation),
                //                    action: AnalyticsTagger.actionString(for: .flechaInferior),
                //                    label: AnalyticsTagger.labelString(for: .next),
                //                    value: nil
                //                )
                self.moveToNextStep()
            case .push:
                assert(OnboardingConfiguration().shouldRegisterForPush)
                self.displayAlertsConfiguration()
            case .blocking:
                assertionFailure("should not have reached this")
            case .customDesign(let identifier):
                #warning("TODO: How could we change this Any to some concrete type? ")
            case .defaultDesign(let identifier):
                #warning("TODO: Make a WhatsNewVC by asking for correct data somewhere")
            }
        }

        return step.viewController(action: action)
    }

    private func displayAlertsConfiguration() {
        #warning("TODO: Recover")
        /*
                let alertsVC = Customization.flavor().alertsViewController(inOnboarding: true, completion: { subscriptionsCount in
                    StartupValues.markAlertsVCAsVisited()

                    if subscriptionsCount > 0 {
                        PushPermissionState.currentState { (state) in
                            switch state {
                            case .accepted:
                                self.moveToNextStep()
                            case .denied:
                                let settingsAction = UIAlertAction(title: NSLocalizedString("Ir a ajustes", comment: ""), style: .default) { _ in
                                    self.goToSettings()
                                }
                                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .cancel) { _ in
                                    self.moveToNextStep()
                                }
                                self.presentAlertWith(title: NSLocalizedString("Alertas deshabilitadas", comment: ""), message: NSLocalizedString("Habilita las alertas push para recibir notificaciones sobre tu contenido favorito.", comment: ""), actions: [settingsAction, cancelAction])
                            case .notPrompted:
                                GGPushManager.sharedInstance().register { (granted) in
                                    DispatchQueue.main.async {
                                        if !granted {
                                            let msg = NSLocalizedString("No se enviarán notificaciones de las suscripciones habilitadas hasta que las notificaciones push estén activadas.", comment: "")
                                            self.presentOKAlert(msg) {
                                                self.moveToNextStep()
                                            }
                                        } else {
                                            self.moveToNextStep()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.moveToNextStep()
                    }
                })

                let navigationController = DICustomNavigationViewController(rootViewController: alertsVC)
                navigationController.modalPresentationStyle = .fullScreen

                alertsVC.configureLVBlueBar()

                present(navigationController, animated: true, completion: nil)
         */
    }

    private func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }

        wasRoutedToSettings = true
    }

    private func displayRegister() {
        #warning("TODO: Recover")
        /*
         authHandler = GGLVAuthPresentationHandler()
         authHandler?.displayRegister(from: self, completion: { _ in
             //Do not act with the token passed back here - let the authHandler post the kUserAuthStatusChanged notification to maintain the iOS >= 12 version code as close as possible to the iOS < 12 version
         })
          */
    }

    // MARK: Aux methods

    private func storeToken(_: String) {
        #warning("TODO: Recover")
//        keychainHandler.save(token: token)
    }

    private func fetchUserData() {
        #warning("TODO: Recover")
//        guard let userManager = GGUserPreferencesManager.sharedInstance() else {
//            return
//        }
//
//        userManager.getUserInfo { (error, statusCode) in
//            if let desc = error?.localizedDescription {
//                print("-----> ERROR GETTING USER DATA: \(desc)")
//            }
//        }
    }
}

private extension OnboardingRootViewController {
    func presentOKAlert(_ message: String, completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            completion()
        }))

        present(alertController, animated: true, completion: nil)
    }

    func presentAlertWith(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alertController.addAction(action)
        }

        present(alertController, animated: true, completion: nil)
    }
}
