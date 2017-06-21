import XCTest
@testable import Cosmic

class CosmicTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Cosmic().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
