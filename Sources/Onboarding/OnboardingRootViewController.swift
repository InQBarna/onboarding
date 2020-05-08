import UIKit
import WhatsNewKit
import SafariServices

class OnboardingRootViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!

    var steps = [OnboardingStep]()
    private var activeStep = 0
    private var wasRoutedToSettings = false

    private var authHandler: GGLVAuthPresentationHandler? //retain for the ASWebAuthenticationSession to work properly

    lazy private var keychainHandler: CredentialsHandling = {
        return LocksmithCredentialsHandler()
    }()

    var onFinishOnboarding: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        displayActiveStep()

        addObservers()
    }

    deinit {
        removeObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupView() {
        view.backgroundColor = Customization.flavor().onboardingBackgroundColor()

        pageControl.numberOfPages = steps.count
        pageControl.currentPage = activeStep

        configureLVBlueBar()
        configureLVLogoBarTitle()

        tintStatusBarWhite()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStatusChanged(_:)),
            name: NSNotification.Name(rawValue: kUserAuthStatusChanged),
            object: nil)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func didBecomeActive() {
        let step = steps[activeStep]
        switch  step {
        case .login, .whatsNew, .blocking:
            break
        case .push:
            if wasRoutedToSettings {
                moveToNextStep()
            }
        }

        wasRoutedToSettings = false
    }

    @objc private func authStatusChanged(_ notification: Notification) {
        let step = steps[activeStep]
        switch  step {
        case .login:
            if let data = notification.userInfo as? [String: String] {
                if let token = data[kUserAuthParamToken] {
                    storeToken(token)
                    fetchUserData()
                    presentedViewController?.dismiss(animated: true) {
                        self.moveToNextStep()
                    }
                }
            }
            break
        case .push, .whatsNew, .blocking:
            break
        }
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
        if let finishClosure = self.onFinishOnboarding {
            finishClosure()
        }
    }

    private func makeViewController(at index: Int) -> UIViewController? {
        return steps[index].viewController { (step, actionSelected) in
            switch step {
            case .whatsNew:
                GGAnalyticsManager.shared()?.trackEvent(
                    withCategory: AnalyticsTagger.categoryString(for: .navigation),
                    action: AnalyticsTagger.actionString(for: .flechaInferior),
                    label: AnalyticsTagger.labelString(for: .next),
                    value: nil
                )
                self.moveToNextStep()
            case .push:
                assert(Customization.flavor().shouldRegisterForPush())
                self.displayAlertsConfiguration()
            case .login:
                guard let action = actionSelected as? LoginBenefitsAction else {
                    assertionFailure("should have returned a LoginBenefitsAction")
                    return
                }
                switch action {
                case .goToLogin:
                    self.displayLogin()
                case .goToRegister:
                    self.displayRegister()
                case .remindLater:
                    GGAnalyticsManager.shared()?.trackEvent(
                        withCategory: AnalyticsTagger.categoryString(for: .signwall),
                        action: AnalyticsTagger.actionString(for: .later),
                        label: nil,
                        value: nil
                    )
                    self.moveToNextStep()
                }
            case .blocking:
                assertionFailure("should not have reached this")
                break
            }
        }
    }

    private func displayAlertsConfiguration() {
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

    private func displayLogin() {
        authHandler = GGLVAuthPresentationHandler()
        authHandler?.displayLogin(from: self, completion: { _ in
            //Do not act with the token passed back here - let the authHandler post the kUserAuthStatusChanged notification to maintain the iOS >= 12 version code as close as possible to the iOS < 12 version
        })
    }

    private func displayRegister() {
        authHandler = GGLVAuthPresentationHandler()
        authHandler?.displayRegister(from: self, completion: { _ in
            //Do not act with the token passed back here - let the authHandler post the kUserAuthStatusChanged notification to maintain the iOS >= 12 version code as close as possible to the iOS < 12 version
        })
    }

    //MARK Aux methods
    private func storeToken(_ token: String) {
        keychainHandler.save(token: token)
    }

    private func fetchUserData() {
        guard let userManager = GGUserPreferencesManager.sharedInstance() else {
            return
        }

        userManager.getUserInfo { (error, statusCode) in
            if let desc = error?.localizedDescription {
                print("-----> ERROR GETTING USER DATA: \(desc)")
            }
        }
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
