import Alamofire
import Combine
import Foundation
@testable import IOSMarketplaceProductApp

/// HTTP stub used by service-layer unit tests.
final class StubHTTPClient: HTTPClienting {
    var requestEmptyResult: Result<Void, APIError> = .success(())
    var responseData: Data?

    func request<T: Decodable>(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<T, APIError> {
        guard let responseData else {
            return Fail(error: APIError.noData).eraseToAnyPublisher()
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let value = try decoder.decode(T.self, from: responseData)
            return Just(value).setFailureType(to: APIError.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: APIError.decodingFailed(error.localizedDescription)).eraseToAnyPublisher()
        }
    }

    func requestEmpty(
        path: String,
        method: APIHTTPMethod,
        parameters: [String: Any]?,
        encoding: ParameterEncoding,
        requiresAuth: Bool
    ) -> AnyPublisher<Void, APIError> {
        switch requestEmptyResult {
        case .success:
            return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
