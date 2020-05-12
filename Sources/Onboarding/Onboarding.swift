import UIKit

public class Onboarding: NSObject {
    private var activeSteps: [OnboardingStep]?
    private var userSteps: [OnboardingStep]

    public init(steps: [OnboardingStep]) {
        userSteps = steps
        super.init()
    }

    private override init() {
        userSteps = []
        assertionFailure("should initalize Onboarding with some Onboarding steps")
    }

    public func shouldPresent(_ completion: @escaping ((Bool) -> Void)) {
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

    public func present(over vc: UIViewController) {
        let onboardingNavController = onboardingRootNavigationController()

        if vc.view.traitCollection.horizontalSizeClass == .compact {
            onboardingNavController.modalPresentationStyle = .fullScreen
        } else {
            self.configurePopoverPresentation(onboardingNavController, over: vc)
        }

        #warning("TODO: Inform on finish")
//        onboardingRootVC.onFinishOnboarding = {
//            self.moveOnFromOnboarding()
//        }

        vc.present(onboardingNavController, animated: true, completion: nil)
    }

    func calculateActiveSteps(_ completion: @escaping (() -> Void)) {
        activeSteps = [OnboardingStep]()

        let group = DispatchGroup()

        userSteps.forEach {
            group.enter()
            let step = $0
            step.shouldDisplay { isActive in
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
        let onboardingRootVC = OnboardingRootViewController()
        onboardingRootVC.steps = activeSteps ?? []

        let navController = UINavigationController(rootViewController: onboardingRootVC)

        return navController
    }

    private func configurePopoverPresentation(_ vc: UIViewController, over: UIViewController) {
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = over.view
        vc.popoverPresentationController?.sourceRect = CGRect(x: (over.view.bounds.midX ?? 0.0), y: (over.view.bounds.midY ?? 0.0), width: 0.0, height: 0.0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        vc.popoverPresentationController?.delegate = self

        vc.preferredContentSize = CGSize(width: 600.0, height: 800.0)
    }

}

extension Onboarding: UIPopoverPresentationControllerDelegate {
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }

    public func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        let preferredContentSize = popoverPresentationController.presentedViewController.preferredContentSize
        let viewFrame = popoverPresentationController.presentingViewController.view.frame
        rect.pointee = CGRect(
            x: viewFrame.midX - preferredContentSize.width / 2.0,
            y: viewFrame.midY - preferredContentSize.height / 2.0,
            width: preferredContentSize.width,
            height: preferredContentSize.height)
    }
}
