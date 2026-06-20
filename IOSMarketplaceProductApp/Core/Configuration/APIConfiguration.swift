import Foundation

/// Central place for API base URL and feature flags. Override via scheme environment or `UserDefaults`.
struct APIConfiguration: Sendable {
    static var shared: APIConfiguration {
        APIConfiguration(
            baseURL: Self.resolvedBaseURL(),
            keychainService: "com.marketplace.app.auth"
        )
    }

    let baseURL: URL
    let keychainService: String

    private static func resolvedBaseURL() -> URL {
        if
            let override = UserDefaults.standard.string(forKey: "marketplace.api.baseURL"),
            let url = URL(string: override), !override.isEmpty
        {
            return url
        }
        if let env = ProcessInfo.processInfo.environment["MARKETPLACE_API_BASE_URL"],
           let url = URL(string: env), !env.isEmpty {
            return url
        }
        // Default for Simulator / local Laravel (`php artisan serve` → http://127.0.0.1:8000)
        return URL(string: "http://127.0.0.1:8000")!
    }
}
