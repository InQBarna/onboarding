@testable import Onboarding
import XCTest

final class OnboardingTests: XCTestCase {
    var sut: Onboarding!
    var testConfig = OnboardingTestConfigSpy()

    class OnboardingPresenterSpy: UIViewController {
        var presentCalled = false

        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentCalled = true
        }
    }

    class OnboardingRootVCSpy: OnboardingRootViewController {
        var dismissCalled = false

        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCalled = true
        }
    }

    func testOnboardingShouldNotDisplayWithVersion000() {
        sut = Onboarding(steps: [.blocking(minVersion: "0.0.0", appStoreUrlString: "test")],
                         configuration: testConfig)
        let expect = XCTestExpectation(description: "should not block with 0.0.0 version")

        sut.checkIfShouldPresent { should in
            if !should {
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testOnboardingShouldDisplayWithWhatsNewStep() {
        sut = Onboarding(steps: [.whatsNew], configuration: testConfig)
        let expect = XCTestExpectation(description: "should display onboard with whatsNew step")

        sut.checkIfShouldPresent { should in
            if should {
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testOnboardingShouldDisplayWithCustomStep() {
        sut = Onboarding(steps: [.custom(identifier: "id", vc: UIViewController())],
                         configuration: testConfig)
        let expect = XCTestExpectation(description: "should display onboard with custom step")

        sut.checkIfShouldPresent { should in
            if should {
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 1)
    }

    func testOnboardingPresentsCorrectly() {
        sut = Onboarding(steps: [.custom(identifier: "id", vc: UIViewController())],
                         configuration: testConfig)
        let presenterVC = OnboardingPresenterSpy()

        sut.present(over: presenterVC, finish: { })

        XCTAssertNotNil(presenterVC.presentCalled)
    }

    func testOnboardingCreatesItsRootViewController() {
        sut = Onboarding(steps: [.custom(identifier: "id", vc: UIViewController())],
                         configuration: testConfig)
        let presenterVC = OnboardingPresenterSpy()

        sut.present(over: presenterVC, finish: { })

        XCTAssert(sut.onboardingRootViewController != nil)
    }

    func testOnboardingCorrectlyMovesToNextStep() {
        let step1VC = UIViewController()
        let step2VC = UIViewController()
        sut = Onboarding(steps: [.custom(identifier: "id1", vc: step1VC),
                                 .custom(identifier: "id2", vc: step2VC),],
                         configuration: testConfig)
        let presenterVC = OnboardingPresenterSpy()
        let expect = XCTestExpectation(description: "should call OnboardingRootVC moveToNextStep")

        sut.checkIfShouldPresent {_ in
            self.sut.present(over: presenterVC, finish: { })
            self.sut.moveToNextStep()

            if self.sut.onboardingRootViewController?.activeStep == 1 {
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 1.0)
    }

    func testOnboardingCorrectlyCallsFinish() {
        sut = Onboarding(steps: [ .custom(identifier: "id1", vc: UIViewController())],
                         configuration: testConfig)
        let presenterVC = OnboardingPresenterSpy()
        let expect = XCTestExpectation(description: "should call OnboardingRootVC moveToNextStep")

        sut.checkIfShouldPresent {_ in
            self.sut.present(over: presenterVC, finish: {
                expect.fulfill()
            })
            self.sut.moveToNextStep()
        }

        wait(for: [expect], timeout: 1.0)
    }

    func testOnboardingDismissesCorrectly() {
        let steps: [OnboardingStep] = [.custom(identifier: "id", vc: UIViewController())]
        sut = Onboarding(steps: steps,
                         configuration: testConfig)
        let vc = UIViewController()
        let spy = OnboardingRootVCSpy(config: testConfig, onboardingSteps: steps)

        sut.present(over: vc, finish: { })
        sut.onboardingRootViewController = spy

        sut.dismiss()

        XCTAssert(spy.dismissCalled)
    }

}
