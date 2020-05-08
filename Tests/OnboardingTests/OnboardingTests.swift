import XCTest
@testable import Onboarding

final class OnboardingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Onboarding().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
