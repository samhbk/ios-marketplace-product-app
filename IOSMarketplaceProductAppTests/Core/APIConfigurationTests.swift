import XCTest
@testable import IOSMarketplaceProductApp

final class APIConfigurationTests: XCTestCase {
    private let userDefaultsKey = "marketplace.api.baseURL"

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        super.tearDown()
    }

    func testSharedDefaultsToLocalhost() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        let config = APIConfiguration.shared
        XCTAssertEqual(config.baseURL.absoluteString, "http://127.0.0.1:8000")
        XCTAssertEqual(config.keychainService, "com.marketplace.app.auth")
    }

    func testUserDefaultsOverridesBaseURL() {
        UserDefaults.standard.set("https://api.example.com", forKey: userDefaultsKey)
        let config = APIConfiguration.shared
        XCTAssertEqual(config.baseURL.absoluteString, "https://api.example.com")
    }

    func testCustomConfigurationPreservesValues() {
        let url = URL(string: "https://staging.example.com")!
        let config = APIConfiguration(baseURL: url, keychainService: "com.example.test")
        XCTAssertEqual(config.baseURL, url)
        XCTAssertEqual(config.keychainService, "com.example.test")
    }
}
