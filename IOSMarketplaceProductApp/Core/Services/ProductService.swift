import Alamofire
import Combine
import Foundation

protocol ProductServicing: AnyObject {
    func fetchProducts(page: Int, perPage: Int) -> AnyPublisher<PaginatedResult<Product>, APIError>
    func fetchProduct(id: Int) -> AnyPublisher<Product, APIError>
}

final class ProductService: ProductServicing {
    private let client: HTTPClienting

    init(client: HTTPClienting) {
        self.client = client
    }

    func fetchProducts(page: Int, perPage: Int) -> AnyPublisher<PaginatedResult<Product>, APIError> {
        client.request(
            path: "/api/products",
            method: .get,
            parameters: [
                "page": page,
                "per_page": perPage
            ],
            encoding: URLEncoding.queryString,
            requiresAuth: true
        )
    }

    func fetchProduct(id: Int) -> AnyPublisher<Product, APIError> {
        client.request(
            path: "/api/products/\(id)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            requiresAuth: true
        )
    }
}
