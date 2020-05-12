import SafariServices
import UIKit
import WhatsNewKit

public class OnboardingRootViewController: UIViewController {
    public var steps = [OnboardingStep]()
    public var activeStep = 0

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

    var onFinishOnboarding: (() -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()

        displayActiveStep()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
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

    func moveToNextStep() {
        if activeStep + 1 < steps.count {
            activeStep += 1
            displayActiveStep()
            pageControl.currentPage = activeStep
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        onFinishOnboarding?()
    }

    private func makeViewController(at index: Int) -> UIViewController? {
        let step = steps[index]

        let action: ((OnboardingStep, Any) -> Void) = { (step, response) in
            switch step {
            case .whatsNew:
                self.moveToNextStep()
            case .blocking, .custom:
                assertionFailure("should not have reached this")
            }
        }

        return step.viewController(action: action)
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
