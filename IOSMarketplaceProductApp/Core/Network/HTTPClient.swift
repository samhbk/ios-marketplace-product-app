import Alamofire
import Combine
import Foundation

protocol HTTPClienting: AnyObject {
    func request<T: Decodable>(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<T, APIError>

    func requestEmpty(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<Void, APIError>
}

final class HTTPClient: HTTPClienting {
    private let configuration: APIConfiguration
    private let tokenStorage: TokenStoring
    private let session: Session
    private let decoder: JSONDecoder

    init(configuration: APIConfiguration, tokenStorage: TokenStoring, session: Session = .default) {
        self.configuration = configuration
        self.tokenStorage = tokenStorage
        self.session = session
        self.decoder = JSONDecoder.marketplaceAPI()
    }

    func request<T: Decodable>(
        path: String,
        method: APIHTTPMethod = .get,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        requiresAuth: Bool = true
    ) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: path, relativeTo: configuration.baseURL) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var headers = HTTPHeaders.default
        headers.add(.accept("application/json"))
        if requiresAuth, let token = tokenStorage.accessToken {
            headers.add(.authorization(bearerToken: token))
        }

        let afMethod = Alamofire.HTTPMethod(rawValue: method.rawValue)

        return session
            .request(
                url,
                method: afMethod,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .publishData()
            .tryMap { [decoder] response -> T in
                if let error = response.error {
                    throw Self.mapAFError(error, data: response.data)
                }
                guard let data = response.data, !data.isEmpty else {
                    throw APIError.noData
                }
                if response.response?.statusCode == 401 {
                    throw APIError.unauthorized
                }
                if let status = response.response?.statusCode, status >= 400 {
                    let message = Self.extractMessage(from: data)
                    throw APIError.server(status: status, message: message)
                }
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingFailed(error.localizedDescription)
                }
            }
            .mapError { error -> APIError in
                if let api = error as? APIError { return api }
                return APIError.unknown(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func requestEmpty(
        path: String,
        method: APIHTTPMethod = .post,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        requiresAuth: Bool = true
    ) -> AnyPublisher<Void, APIError> {
        guard let url = URL(string: path, relativeTo: configuration.baseURL) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var headers = HTTPHeaders.default
        headers.add(.accept("application/json"))
        if requiresAuth, let token = tokenStorage.accessToken {
            headers.add(.authorization(bearerToken: token))
        }

        let afMethod = Alamofire.HTTPMethod(rawValue: method.rawValue)

        return session
            .request(
                url,
                method: afMethod,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .publishData()
            .tryMap { response -> Void in
                if let error = response.error {
                    throw Self.mapAFError(error, data: response.data)
                }
                if response.response?.statusCode == 401 {
                    throw APIError.unauthorized
                }
                if let status = response.response?.statusCode, status >= 400 {
                    let message = response.data.flatMap { Self.extractMessage(from: $0) }
                    throw APIError.server(status: status, message: message)
                }
            }
            .mapError { error -> APIError in
                if let api = error as? APIError { return api }
                return APIError.unknown(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    private static func extractMessage(from data: Data) -> String? {
        struct LaravelError: Decodable {
            let message: String?
            let errors: [String: [String]]?
        }
        if let err = try? JSONDecoder().decode(LaravelError.self, from: data) {
            if let message = err.message { return message }
            if let first = err.errors?.values.flatMap({ $0 }).first { return first }
        }
        return String(data: data, encoding: .utf8)
    }

    private static func mapAFError(_ error: AFError, data: Data?) -> APIError {
        if let urlError = error.underlyingError as? URLError {
            return .network(urlError)
        }
        if case .responseValidationFailed(let reason) = error {
            if case .unacceptableStatusCode(let code) = reason {
                let message = data.flatMap { extractMessage(from: $0) }
                if code == 401 { return .unauthorized }
                return .server(status: code, message: message)
            }
        }
        return .unknown(error.localizedDescription)
    }
}
