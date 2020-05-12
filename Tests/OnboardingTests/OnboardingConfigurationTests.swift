@testable import Onboarding
import WhatsNewKit
import XCTest

final class OnboardingConfigurationTests: XCTestCase {
    var sut: OnboardingRootViewController!
    var sutNavController: UINavigationController!

    var spy = OnboardingTestConfigSpy()
    lazy var steps: [OnboardingStep] = {
        return [ .custom(identifier: "id", vc: UIViewController()),
                 .custom(identifier: "id2", vc: whatsNewTestVC)]
    }()

    var window: UIWindow!

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSut()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    func loadView() {
        window.addSubview(sutNavController.view)
        RunLoop.current.run(until: Date())
    }

    func setupSut() {
        sut = OnboardingRootViewController(
            config: spy,
            onboardingSteps: steps)

        sutNavController = UINavigationController(rootViewController: sut)
    }

    var whatsNewTestVC: OnboardingViewController {
        let item = WhatsNew.Item(title: "Item",
                                 subtitle: "subtitle",
                                 image: nil)
        let whatsNew = WhatsNew(title: "test",
                                items: [item])

        return OnboardingViewController(whatsNew: whatsNew, configuration: OnboardingSceneBuilder.defaultCustomizedConfiguration(config: spy, {
        }))
    }

    func testOnboardingCofiguresBackgroundColor() {
        loadView()

        XCTAssertEqual(sut.view.backgroundColor, spy.backgroundColor(forStep: steps.first!))
        XCTAssert(spy.backgroundColorForStepCalled)
    }

    func testOnboardingConfiguresStatusBarStyle() {
        loadView()

        XCTAssertEqual(sut.preferredStatusBarStyle, spy.statusBarStyle)
    }

    func testOnboardingConfiguresNavBar() {
        loadView()

        XCTAssert(spy.configureNavBarCalled)
    }

    func testOnboardingConfiguresNavBarVisibility() {
        loadView()

        XCTAssert(spy.hidesNavBarCalled)
    }

    func testOnboardingSceneBuilderConfiguresTitle() {
        _ = OnboardingSceneBuilder.defaultCustomizedConfiguration(config: spy) {

        }

        XCTAssert(spy.titleFontCalled)
        XCTAssert(spy.titleColorCalled)
    }

    func testOnboardingSceneBuilderConfiguresPrimaryText() {
        _ = OnboardingSceneBuilder.defaultCustomizedConfiguration(config: spy) {

        }

        XCTAssert(spy.primaryFontCalled)
        XCTAssert(spy.primaryTextColorCalled)
    }

    func testOnboardingSceneBuilderConfiguresSecondaryText() {
        _ = OnboardingSceneBuilder.defaultCustomizedConfiguration(config: spy) {

        }

        XCTAssert(spy.secondaryFontCalled)
        XCTAssert(spy.secondaryTextColorCalled)
    }

    func testOnboardingSceneBuilderConfiguresCompletionButton() {
        _ = OnboardingSceneBuilder.defaultCustomizedConfiguration(config: spy) {

        }

        XCTAssert(spy.completionButtonInsetsCalled)
        XCTAssert(spy.completionButtonTitleFontCalled)
        XCTAssert(spy.completionButtonTitleColorCalled)
        XCTAssert(spy.completionButtonBackgroundColorCalled)
    }
    
    func testOnboardingWhatsNewAsksForCleanInstallJsonName() {
        _ = OnboardingStep.whatsNew.viewController(config: spy) { (_, _) in

        }

        XCTAssert(spy.firstInstallWhatsNewJsonNameCalled)
    }
}

