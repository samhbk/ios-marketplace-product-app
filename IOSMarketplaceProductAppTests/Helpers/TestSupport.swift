import Alamofire
import Combine
import Foundation
@testable import IOSMarketplaceProductApp

// MARK: - HTTP

final class MockHTTPClient: HTTPClienting {
    var lastRequest: (path: String, method: APIHTTPMethod, requiresAuth: Bool)?

    func request<T: Decodable>(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<T, APIError> {
        lastRequest = (path, method, requiresAuth)
        return Fail(error: APIError.unknown("MockHTTPClient: no stub configured")).eraseToAnyPublisher()
    }

    func requestEmpty(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<Void, APIError> {
        lastRequest = (path, method, requiresAuth)
        return Fail(error: APIError.unknown("MockHTTPClient: no stub configured")).eraseToAnyPublisher()
    }
}

// MARK: - Auth

final class MockAuthService: AuthServicing {
    var loginResult: Result<AuthResponse, APIError> = .failure(.unknown("not configured"))
    private(set) var lastLogin: (email: String, password: String)?

    func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError> {
        lastLogin = (email, password)
        return loginResult.publisher.eraseToAnyPublisher()
    }
}

// MARK: - Products

final class MockProductService: ProductServicing {
    var fetchProductsResult: Result<PaginatedResult<Product>, APIError> = .failure(.unknown("not configured"))
    var fetchProductResult: Result<Product, APIError> = .failure(.unknown("not configured"))
    private(set) var lastFetchProductsPage: Int?
    private(set) var lastFetchProductID: Int?

    func fetchProducts(page: Int, perPage: Int) -> AnyPublisher<PaginatedResult<Product>, APIError> {
        lastFetchProductsPage = page
        return fetchProductsResult.publisher.eraseToAnyPublisher()
    }

    func fetchProduct(id: Int) -> AnyPublisher<Product, APIError> {
        lastFetchProductID = id
        return fetchProductResult.publisher.eraseToAnyPublisher()
    }
}

// MARK: - Favorites

final class MockFavoritesService: FavoritesServicing {
    private let subject: CurrentValueSubject<Set<Int>, Never>

    init(initialIDs: Set<Int> = []) {
        subject = CurrentValueSubject(initialIDs)
    }

    var favoriteIDsPublisher: AnyPublisher<Set<Int>, Never> {
        subject.eraseToAnyPublisher()
    }

    func favoriteIDs() -> Set<Int> {
        subject.value
    }

    func isFavorite(productID: Int) -> Bool {
        subject.value.contains(productID)
    }

    var toggleResult: Result<Void, APIError> = .success(())
    private(set) var lastToggledID: Int?

    func toggleFavorite(productID: Int) -> AnyPublisher<Void, APIError> {
        lastToggledID = productID
        if subject.value.contains(productID) {
            subject.send(subject.value.subtracting([productID]))
        } else {
            subject.send(subject.value.union([productID]))
        }
        return toggleResult.publisher.eraseToAnyPublisher()
    }

    var fetchFavoriteProductsResult: Result<[Product], APIError> = .success([])
    func fetchFavoriteProducts() -> AnyPublisher<[Product], APIError> {
        fetchFavoriteProductsResult.publisher.eraseToAnyPublisher()
    }

    func syncFromServer() -> AnyPublisher<Void, APIError> {
        Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
    }

    func clearLocalCache() {
        subject.send([])
    }
}

// MARK: - Token storage

final class MockTokenStorage: TokenStoring {
    var accessToken: String?

    func save(accessToken: String) {
        self.accessToken = accessToken
    }

    func clear() {
        accessToken = nil
    }
}

// MARK: - Fixtures

enum TestFixtures {
    static let sampleProduct = Product(
        id: 1,
        name: "Wireless Headphones",
        description: "Noise cancelling",
        price: Decimal(string: "129.99")!,
        currencyCode: "EUR",
        imageURL: URL(string: "https://cdn.example.com/headphones.jpg"),
        category: "Electronics"
    )

    static let sampleUser = User(id: 42, name: "Demo User", email: "demo@example.com")

    static func paginated(products: [Product], currentPage: Int = 1, lastPage: Int = 1) -> PaginatedResult<Product> {
        let json = """
        {
          "data": \(encodeProducts(products)),
          "meta": {
            "current_page": \(currentPage),
            "last_page": \(lastPage),
            "per_page": 20,
            "total": \(products.count)
          }
        }
        """
        return try! JSONDecoder().decode(PaginatedResult<Product>.self, from: Data(json.utf8))
    }

    private static func encodeProducts(_ products: [Product]) -> String {
        let items = products.map { product in
            """
            {
              "id": \(product.id),
              "name": "\(product.name)",
              "description": \(product.description.map { "\"\($0)\"" } ?? "null"),
              "price": "\(product.price)",
              "currency": "\(product.currencyCode ?? "EUR")",
              "image_url": "\(product.imageURL?.absoluteString ?? "")",
              "category": "\(product.category ?? "")"
            }
            """
        }
        return "[\(items.joined(separator: ","))]"
    }
}

private extension Result {
    var publisher: AnyPublisher<Success, Failure> {
        switch self {
        case .success(let value):
            return Just(value).setFailureType(to: Failure.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
