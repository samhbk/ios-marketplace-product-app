import Alamofire
import Combine
import Foundation

protocol AuthServicing: AnyObject {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError>
}

final class AuthService: AuthServicing {
    private let client: HTTPClienting

    init(client: HTTPClienting) {
        self.client = client
    }

    func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError> {
        client.request(
            path: "/api/login",
            method: .post,
            parameters: [
                "email": email,
                "password": password
            ],
            encoding: JSONEncoding.default,
            requiresAuth: false
        )
    }
}
