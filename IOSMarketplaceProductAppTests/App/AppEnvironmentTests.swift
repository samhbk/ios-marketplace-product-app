import XCTest
@testable import IOSMarketplaceProductApp

@MainActor
final class AppEnvironmentTests: XCTestCase {
    func testSignOutClearsAuthAndFavorites() {
        let storage = MockTokenStorage()
        storage.save(accessToken: "token")
        let favorites = MockFavoritesService(initialIDs: [1, 2])
        let environment = AppEnvironment(
            configuration: APIConfiguration(
                baseURL: URL(string: "https://api.example.com")!,
                keychainService: "test"
            ),
            tokenStorage: storage,
            httpClient: MockHTTPClient(),
            authService: MockAuthService(),
            productService: MockProductService(),
            favoritesService: favorites,
            isAuthenticated: true
        )

        environment.signOut()

        XCTAssertNil(storage.accessToken)
        XCTAssertTrue(favorites.favoriteIDs().isEmpty)
        XCTAssertFalse(environment.isAuthenticated)
    }

    func testApplySignedInStateReflectsToken() {
        let storage = MockTokenStorage()
        let environment = AppEnvironment(
            configuration: APIConfiguration(
                baseURL: URL(string: "https://api.example.com")!,
                keychainService: "test"
            ),
            tokenStorage: storage,
            httpClient: MockHTTPClient(),
            authService: MockAuthService(),
            productService: MockProductService(),
            favoritesService: MockFavoritesService(),
            isAuthenticated: false
        )

        storage.save(accessToken: "fresh-token")
        environment.applySignedIn(user: TestFixtures.sampleUser)
        XCTAssertTrue(environment.isAuthenticated)
    }
}
