import Alamofire
import Combine
import Foundation

protocol FavoritesServicing: AnyObject {
    var favoriteIDsPublisher: AnyPublisher<Set<Int>, Never> { get }
    func favoriteIDs() -> Set<Int>
    func isFavorite(productID: Int) -> Bool
    func toggleFavorite(productID: Int) -> AnyPublisher<Void, APIError>
    func fetchFavoriteProducts() -> AnyPublisher<[Product], APIError>
    func syncFromServer() -> AnyPublisher<Void, APIError>
    func clearLocalCache()
}

/// Persists favorite product IDs locally for instant heart state; syncs with Laravel when possible.
final class FavoritesService: FavoritesServicing {
    private let client: HTTPClienting
    private let storageKey: String
    private let subject: CurrentValueSubject<Set<Int>, Never>

    init(client: HTTPClienting, storageKey: String = "marketplace.favorites.ids") {
        self.client = client
        self.storageKey = storageKey
        let initial = Self.loadFromDisk(key: storageKey) ?? []
        self.subject = CurrentValueSubject(Set(initial))
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

    func toggleFavorite(productID: Int) -> AnyPublisher<Void, APIError> {
        if subject.value.contains(productID) {
            return removeRemote(productID: productID)
        }
        return addRemote(productID: productID)
    }

    func fetchFavoriteProducts() -> AnyPublisher<[Product], APIError> {
        client
            .request(
                path: "/api/favorites",
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                requiresAuth: true
            )
            .map { (envelope: FavoritesProductsEnvelope) in envelope.data }
            .eraseToAnyPublisher()
    }

    func syncFromServer() -> AnyPublisher<Void, APIError> {
        client
            .request(
                path: "/api/favorites",
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                requiresAuth: true
            )
            .handleEvents(receiveOutput: { [weak self] (envelope: FavoritesProductsEnvelope) in
                self?.replaceAll(Set(envelope.data.map(\.id)))
            })
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func clearLocalCache() {
        subject.send([])
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func addRemote(productID: Int) -> AnyPublisher<Void, APIError> {
        client
            .requestEmpty(
                path: "/api/favorites",
                method: .post,
                parameters: ["product_id": productID],
                encoding: JSONEncoding.default,
                requiresAuth: true
            )
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.insertLocal(productID)
            })
            .eraseToAnyPublisher()
    }

    private func removeRemote(productID: Int) -> AnyPublisher<Void, APIError> {
        client
            .requestEmpty(
                path: "/api/favorites/\(productID)",
                method: .delete,
                parameters: nil,
                encoding: URLEncoding.default,
                requiresAuth: true
            )
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.removeLocal(productID)
            })
            .catch { [weak self] error -> AnyPublisher<Void, APIError> in
                if case .network = error {
                    self?.removeLocal(productID)
                    return Just(()).setFailureType(to: APIError.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func insertLocal(_ id: Int) {
        var next = subject.value
        next.insert(id)
        subject.send(next)
        Self.persist(Array(next), key: storageKey)
    }

    private func removeLocal(_ id: Int) {
        var next = subject.value
        next.remove(id)
        subject.send(next)
        Self.persist(Array(next), key: storageKey)
    }

    private func replaceAll(_ ids: Set<Int>) {
        subject.send(ids)
        Self.persist(Array(ids), key: storageKey)
    }

    private static func persist(_ ids: [Int], key: String) {
        UserDefaults.standard.set(ids, forKey: key)
    }

    private static func loadFromDisk(key: String) -> [Int]? {
        UserDefaults.standard.array(forKey: key) as? [Int]
    }
}

private struct FavoritesProductsEnvelope: Decodable {
    let data: [Product]
}
