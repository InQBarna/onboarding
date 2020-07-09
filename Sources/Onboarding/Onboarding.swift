import UIKit

public class Onboarding: NSObject {
    public var activeSteps: [OnboardingStep]?
    private var userSteps: [OnboardingStep]
    private var config: OnboardingConfiguration

    public weak var onboardingRootViewController: OnboardingRootViewController?
    public var activeStep: OnboardingStep? {
        guard let steps = activeSteps,
            let index = onboardingRootViewController?.activeStep else { return nil }
        return steps[index]
    }

    public init(steps: [OnboardingStep], configuration: OnboardingConfiguration) {
        userSteps = steps
        config = configuration
        super.init()
    }

    override private init() {
        fatalError("have to initialize with init(steps: configuration:)")
    }

    public func checkIfShouldPresent(_ completion: @escaping ((Bool) -> Void)) {
        let isOnboardingForcedByActiveSteps = {
            guard let activeStepsForcingOnboard = self.activeSteps?.filter({
                $0.forcesOnboardDisplay()
            }) else {
                completion(false)
                return
            }
            completion(activeStepsForcingOnboard.count > 0)
        }

        if activeSteps == nil {
            calculateActiveSteps {
                isOnboardingForcedByActiveSteps()
            }
        } else {
            isOnboardingForcedByActiveSteps()
        }
    }

    public func present(over vc: UIViewController, finish: @escaping (() -> Void)) {
        let onboardingNavController = onboardingRootNavigationController()

        if vc.view.traitCollection.horizontalSizeClass == .compact {
            onboardingNavController.modalPresentationStyle = .fullScreen
        } else {
            configurePopoverPresentation(onboardingNavController, over: vc)
        }

        onboardingRootViewController?.onFinishOnboarding = {
            finish()
        }

        vc.present(onboardingNavController, animated: true, completion: nil)
    }

    public func dismiss(completion: @escaping (() -> Void)) {
        onboardingRootViewController?.dismiss(animated: true, completion: completion)
    }

    public func moveToNextStep() {
        onboardingRootViewController?.moveToNextStep()
    }

    func calculateActiveSteps(_ completion: @escaping (() -> Void)) {
        activeSteps = [OnboardingStep]()

        let group = DispatchGroup()

        userSteps.forEach {
            group.enter()
            let step = $0
            step.shouldDisplay(config: config) { isActive in
                if isActive {
                    self.activeSteps?.append(step)
                }
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            self.activeSteps?.sort(by: { (step1, step2) -> Bool in
                let index1 = self.userSteps.firstIndex(of: step1) ?? 0
                let index2 = self.userSteps.firstIndex(of: step2) ?? 0
                return index1 < index2
            })
            completion()
        }
    }

    private func onboardingRootNavigationController() -> UINavigationController {
        let onboardingRootVC = OnboardingRootViewController(
            config: config,
            onboardingSteps: activeSteps ?? []
        )

        let navController = OnboardingNavigationController(rootViewController: onboardingRootVC, statusBarStyle: config.statusBarStyle ?? .default)
        onboardingRootViewController = onboardingRootVC

        return navController
    }

    private func configurePopoverPresentation(_ vc: UIViewController, over: UIViewController) {
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = over.view
        vc.popoverPresentationController?.sourceRect = CGRect(x: over.view.bounds.midX, y: over.view.bounds.midY, width: 0.0, height: 0.0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        vc.popoverPresentationController?.delegate = self

        vc.preferredContentSize = CGSize(width: 600.0, height: 800.0)
    }
}

extension Onboarding: UIPopoverPresentationControllerDelegate {
    public func presentationControllerShouldDismiss(_: UIPresentationController) -> Bool {
        return false
    }

    public func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in _: AutoreleasingUnsafeMutablePointer<UIView>) {
        let preferredContentSize = popoverPresentationController.presentedViewController.preferredContentSize
        let viewFrame = popoverPresentationController.presentingViewController.view.frame
        rect.pointee = CGRect(
            x: viewFrame.midX - preferredContentSize.width / 2.0,
            y: viewFrame.midY - preferredContentSize.height / 2.0,
            width: preferredContentSize.width,
            height: preferredContentSize.height
        )
    }
}
