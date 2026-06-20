import XCTest
@testable import IOSMarketplaceProductApp

final class APIErrorTests: XCTestCase {
    func testUnauthorizedUserMessage() {
        XCTAssertEqual(APIError.unauthorized.userMessage, "Please sign in again.")
    }

    func testServerErrorUsesMessage() {
        let error = APIError.server(status: 422, message: "Validation failed")
        XCTAssertEqual(error.userMessage, "Validation failed")
    }

    func testServerErrorFallbackMessage() {
        let error = APIError.server(status: 500, message: nil)
        XCTAssertEqual(error.userMessage, "Something went wrong on the server.")
    }
}
