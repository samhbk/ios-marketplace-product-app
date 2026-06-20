import Foundation

extension JSONDecoder {
    /// Decoder aligned with Laravel API payloads (`image_url`, `current_page`, etc.).
    /// Do not use `.convertFromSnakeCase` here — models declare explicit `CodingKeys`.
    static func marketplaceAPI() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }
}
