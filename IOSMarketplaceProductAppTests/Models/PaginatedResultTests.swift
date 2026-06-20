import XCTest
@testable import IOSMarketplaceProductApp

final class PaginatedResultTests: XCTestCase {
    func testHasMorePagesWhenCurrentPageBelowLastPage() throws {
        let page = TestFixtures.paginated(products: [TestFixtures.sampleProduct], currentPage: 1, lastPage: 3)
        XCTAssertTrue(page.hasMorePages)
        XCTAssertEqual(page.currentPage, 1)
        XCTAssertEqual(page.lastPage, 3)
    }

    func testHasNoMorePagesOnLastPage() throws {
        let page = TestFixtures.paginated(products: [TestFixtures.sampleProduct], currentPage: 2, lastPage: 2)
        XCTAssertFalse(page.hasMorePages)
    }
}
