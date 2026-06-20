import XCTest
@testable import IOSMarketplaceProductApp

final class ProductDecodingTests: XCTestCase {
    func testDecodesNumericPrice() throws {
        let json = """
        {
          "id": 1,
          "name": "Desk Lamp",
          "price": 49.5,
          "currency": "EUR",
          "image_url": "/images/lamp.jpg",
          "category": "Home"
        }
        """
        let product = try JSONDecoder().decode(Product.self, from: Data(json.utf8))
        XCTAssertEqual(product.id, 1)
        XCTAssertEqual(product.name, "Desk Lamp")
        XCTAssertEqual(product.price, Decimal(string: "49.5"))
        XCTAssertEqual(product.currencyCode, "EUR")
        XCTAssertEqual(product.category, "Home")
    }

    func testDecodesStringPrice() throws {
        let json = """
        { "id": 2, "name": "Mug", "price": "12.00" }
        """
        let product = try JSONDecoder().decode(Product.self, from: Data(json.utf8))
        XCTAssertEqual(product.price, Decimal(string: "12.00"))
    }

    func testDecodesMissingOptionalFields() throws {
        let json = """
        { "id": 3, "name": "Sticker" }
        """
        let product = try JSONDecoder().decode(Product.self, from: Data(json.utf8))
        XCTAssertNil(product.description)
        XCTAssertNil(product.imageURL)
        XCTAssertEqual(product.price, 0)
    }

    func testResolvedImageURLWithRelativePath() {
        let product = Product(
            id: 1,
            name: "Item",
            description: nil,
            price: 1,
            currencyCode: nil,
            imageURL: URL(string: "/storage/products/1.jpg"),
            category: nil
        )
        let resolved = product.resolvedImageURL(relativeTo: URL(string: "https://api.example.com")!)
        XCTAssertEqual(resolved?.absoluteString, "https://api.example.com/storage/products/1.jpg")
    }
}
