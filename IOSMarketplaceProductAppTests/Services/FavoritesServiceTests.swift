import Combine
import XCTest
@testable import IOSMarketplaceProductApp

final class FavoritesServiceTests: XCTestCase {
    private let storageKey = "marketplace.favorites.ids.tests"
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        cancellables.removeAll()
        super.tearDown()
    }

    func testPersistsFavoriteAfterSuccessfulAdd() {
        let client = StubHTTPClient()
        client.requestEmptyResult = .success(())
        let service = FavoritesService(client: client, storageKey: storageKey)

        let expectation = expectation(description: "favorite added")
        service.toggleFavorite(productID: 99)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(service.isFavorite(productID: 99))
        XCTAssertEqual(UserDefaults.standard.array(forKey: storageKey) as? [Int], [99])
    }

    func testClearLocalCacheRemovesFavorites() {
        UserDefaults.standard.set([1, 2], forKey: storageKey)
        let service = FavoritesService(client: StubHTTPClient(), storageKey: storageKey)
        XCTAssertEqual(service.favoriteIDs(), Set([1, 2]))

        service.clearLocalCache()
        XCTAssertTrue(service.favoriteIDs().isEmpty)
        XCTAssertNil(UserDefaults.standard.array(forKey: storageKey))
    }

    func testSyncFromServerReplacesLocalIDs() {
        let client = StubHTTPClient()
        client.responseData = Data(
            """
            {
              "data": [
                { "id": 10, "name": "Item", "price": "9.99" },
                { "id": 11, "name": "Item B", "price": "4.50" }
              ]
            }
            """.utf8
        )
        let service = FavoritesService(client: client, storageKey: storageKey)

        let expectation = expectation(description: "synced")
        service.syncFromServer()
            .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(service.favoriteIDs(), Set([10, 11]))
    }
}
