import Combine
import Foundation

/// App-wide dependencies (injectable for tests).
final class AppEnvironment: ObservableObject {
    let configuration: APIConfiguration
    let tokenStorage: TokenStoring
    let httpClient: HTTPClienting
    let authService: AuthServicing
    let productService: ProductServicing
    let favoritesService: FavoritesServicing

    @Published private(set) var isAuthenticated: Bool
    @Published private(set) var currentUser: User?

    init(
        configuration: APIConfiguration,
        tokenStorage: TokenStoring,
        httpClient: HTTPClienting,
        authService: AuthServicing,
        productService: ProductServicing,
        favoritesService: FavoritesServicing,
        isAuthenticated: Bool? = nil
    ) {
        self.configuration = configuration
        self.tokenStorage = tokenStorage
        self.httpClient = httpClient
        self.authService = authService
        self.productService = productService
        self.favoritesService = favoritesService
        self.isAuthenticated = isAuthenticated ?? (tokenStorage.accessToken != nil)
    }

    convenience init(configuration: APIConfiguration = .shared) {
        let storage = KeychainTokenStorage(service: configuration.keychainService)
        let client = HTTPClient(configuration: configuration, tokenStorage: storage)
        self.init(
            configuration: configuration,
            tokenStorage: storage,
            httpClient: client,
            authService: AuthService(client: client),
            productService: ProductService(client: client),
            favoritesService: FavoritesService(client: client),
            isAuthenticated: storage.accessToken != nil
        )
    }

    func applySignedIn(user: User? = nil) {
        currentUser = user
        isAuthenticated = tokenStorage.accessToken != nil
    }

    func signOut() {
        tokenStorage.clear()
        favoritesService.clearLocalCache()
        currentUser = nil
        isAuthenticated = false
    }
}
