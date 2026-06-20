import XCTest
@testable import IOSMarketplaceProductApp

final class PriceFormatterTests: XCTestCase {
    func testFormatsEURPrice() {
        let formatted = PriceFormatter.string(for: Decimal(string: "129.99")!, currencyCode: "EUR")
        XCTAssertTrue(formatted.contains("129"))
        XCTAssertTrue(formatted.contains("99") || formatted.contains("00"))
    }

    func testFallsBackWhenCurrencyMissing() {
        let formatted = PriceFormatter.string(for: Decimal(10), currencyCode: nil)
        XCTAssertFalse(formatted.isEmpty)
    }
}
