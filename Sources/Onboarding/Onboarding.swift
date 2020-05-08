class Onboarding {

    private var activeSteps: [OnboardingStep]?

    func calculateActiveSteps(_ completion: @escaping (() -> Void)) {
        activeSteps = [OnboardingStep]()

        let group = DispatchGroup()

        OnboardingStep.allCases.forEach({
            group.enter()
            let step = $0
            step.shouldDisplay { (isActive) in
                if isActive {
                    self.activeSteps?.append(step)
                }
                group.leave()
            }
        })

        group.notify(queue: DispatchQueue.main) {
            self.activeSteps?.sort(by: { (step1, step2) -> Bool in
                return step1.rawValue < step2.rawValue
            })
            completion()
        }
    }

    func shouldPresentOnboarding() -> Bool {
        guard let activeStepsForcingOnboard = activeSteps?.filter({
            $0.forcesOnboardDisplay()
        }) else {
            assertionFailure("should have called calculateActiveSteps first and have waited for a result")
            return false
        }
        return activeStepsForcingOnboard.count > 0
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


