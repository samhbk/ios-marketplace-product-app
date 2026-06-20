import XCTest
@testable import IOSMarketplaceProductApp

final class AuthResponseDecodingTests: XCTestCase {
    func testDecodesFlatTokenResponse() throws {
        let json = """
        {
          "token": "abc123",
          "user": { "id": 1, "name": "Alex", "email": "alex@example.com" }
        }
        """
        let response = try JSONDecoder().decode(AuthResponse.self, from: Data(json.utf8))
        XCTAssertEqual(response.bearerToken, "abc123")
        XCTAssertEqual(response.user?.email, "alex@example.com")
    }

    func testDecodesAccessTokenField() throws {
        let json = """
        { "access_token": "jwt-token", "user": { "id": 2, "name": "Sam", "email": "sam@example.com" } }
        """
        let response = try JSONDecoder().decode(AuthResponse.self, from: Data(json.utf8))
        XCTAssertEqual(response.bearerToken, "jwt-token")
    }

    func testDecodesWrappedDataEnvelope() throws {
        let json = """
        {
          "data": {
            "token": "nested-token",
            "user": { "id": 3, "name": "Jo", "email": "jo@example.com" }
          }
        }
        """
        let response = try JSONDecoder().decode(AuthResponse.self, from: Data(json.utf8))
        XCTAssertEqual(response.bearerToken, "nested-token")
        XCTAssertEqual(response.user?.name, "Jo")
    }
}
