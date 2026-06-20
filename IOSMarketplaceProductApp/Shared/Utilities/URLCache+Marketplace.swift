import Foundation

extension URLCache {
    static func configureMarketplaceCache() {
        let memory = 64 * 1_024 * 1_024
        let disk = 256 * 1_024 * 1_024
        URLCache.shared = URLCache(
            memoryCapacity: memory,
            diskCapacity: disk,
            directory: nil
        )
    }
}

extension Product {
    func resolvedImageURL(relativeTo base: URL) -> URL? {
        guard let imageURL else { return nil }
        if imageURL.scheme != nil { return imageURL }
        return URL(string: imageURL.absoluteString, relativeTo: base)?.absoluteURL
    }
}
