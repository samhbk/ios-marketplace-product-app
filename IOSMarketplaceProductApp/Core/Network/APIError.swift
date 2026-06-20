import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case noData
    case decodingFailed(String)
    case unauthorized
    case server(status: Int, message: String?)
    case network(URLError)
    case unknown(String)

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid request."
        case .noData:
            return "No data returned from the server."
        case .decodingFailed:
            return "Could not read the server response."
        case .unauthorized:
            return "Please sign in again."
        case .server(_, let message):
            return message ?? "Something went wrong on the server."
        case .network(let urlError):
            return urlError.localizedDescription
        case .unknown(let message):
            return message
        }
    }
}
