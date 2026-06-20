import Combine
import XCTest
@testable import IOSMarketplaceProductApp

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadSetsProductsOnSuccess() {
        let favorites = MockFavoritesService()
        let product = TestFixtures.sampleProduct
        favorites.fetchFavoriteProductsResult = .success([product])

        let viewModel = FavoritesViewModel(
            favoritesService: favorites,
            productService: MockProductService()
        )
        let expectation = expectation(description: "favorites loaded")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loaded = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.id, product.id)
    }

    func testLoadFailureSetsFailedState() {
        let favorites = MockFavoritesService()
        favorites.fetchFavoriteProductsResult = .failure(.server(status: 503, message: "Unavailable"))

        let viewModel = FavoritesViewModel(
            favoritesService: favorites,
            productService: MockProductService()
        )
        let expectation = expectation(description: "failed state")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failed(let message) = state, message == "Unavailable" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.products.isEmpty)
    }

    func testLoadClearsBannerError() {
        let favorites = MockFavoritesService()
        favorites.fetchFavoriteProductsResult = .success([TestFixtures.sampleProduct])

        let viewModel = FavoritesViewModel(
            favoritesService: favorites,
            productService: MockProductService()
        )
        viewModel.bannerError = "Previous error"

        let expectation = expectation(description: "loaded")
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loaded = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [expectation], timeout: 2)
        XCTAssertNil(viewModel.bannerError)
    }
}
