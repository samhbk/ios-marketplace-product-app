import XCTest
@testable import IOSMarketplaceProductApp

final class LaravelAPIResponseDecodingTests: XCTestCase {
    private let decoder = JSONDecoder.marketplaceAPI()

    func testDecodesLaravelProductPaginatorPayload() throws {
        let json = """
        {
          "data": [
            {
              "id": 1,
              "name": "Wireless Earbuds Pro",
              "description": "Active noise reduction.",
              "price": "79.99",
              "compare_at_price": "99.99",
              "currency": "EUR",
              "image_url": "http://127.0.0.1:8000/demo/products/wireless-earbuds-pro.jpg",
              "category": "Electronics"
            }
          ],
          "links": {
            "first": "http://127.0.0.1:8000/api/products?page=1",
            "last": "http://127.0.0.1:8000/api/products?page=2",
            "prev": null,
            "next": "http://127.0.0.1:8000/api/products?page=2"
          },
          "meta": {
            "current_page": 1,
            "from": 1,
            "last_page": 2,
            "links": [],
            "path": "http://127.0.0.1:8000/api/products",
            "per_page": 20,
            "to": 1,
            "total": 24
          }
        }
        """

        let page = try decoder.decode(PaginatedResult<Product>.self, from: Data(json.utf8))
        XCTAssertEqual(page.data.count, 1)
        XCTAssertEqual(page.data[0].name, "Wireless Earbuds Pro")
        XCTAssertEqual(page.data[0].compareAtPrice, Decimal(string: "99.99"))
        XCTAssertEqual(page.currentPage, 1)
        XCTAssertEqual(page.lastPage, 2)
        XCTAssertTrue(page.hasMorePages)
        XCTAssertEqual(page.meta?.total, 24)
    }
}
