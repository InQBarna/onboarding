import UIKit

public class Onboarding {
    private var activeSteps: [OnboardingStep]?

    public init() {}

    public func shouldPresent(_ completion: @escaping ((Bool) -> Void)) {
        let isOnboardingForcedByActiveSteps = {
            print("activeSteps = \(String(describing: self.activeSteps))")
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

    func calculateActiveSteps(_ completion: @escaping (() -> Void)) {
        activeSteps = [OnboardingStep]()

        let group = DispatchGroup()

        OnboardingStep.allCases.forEach {
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
                step1.rawValue < step2.rawValue
            })
            completion()
        }
    }

    func onboardingRootNavigationController() -> UINavigationController? {
        guard let activeSteps = activeSteps else {
            assertionFailure("should have called calculateActiveSteps first and have waited for a result")
            return nil
        }
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let rootVC = onboardingStoryboard.instantiateInitialViewController() as! UINavigationController
        let onboardingRootVC = rootVC.viewControllers.first as! OnboardingRootViewController

        onboardingRootVC.steps = activeSteps
        return rootVC
    }
}
