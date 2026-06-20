import Combine
import XCTest
@testable import IOSMarketplaceProductApp

@MainActor
final class ProductDetailViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoadSetsProduct() {
        let service = MockProductService()
        let product = TestFixtures.sampleProduct
        service.fetchProductResult = .success(product)

        let viewModel = ProductDetailViewModel(
            productID: product.id,
            productService: service,
            favoritesService: MockFavoritesService(),
            imageBaseURL: URL(string: "https://api.example.com")!
        )

        let expectation = expectation(description: "product loaded")
        viewModel.$loadState
            .dropFirst()
            .sink { state in
                if case .loaded = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.product?.name, product.name)
        XCTAssertEqual(service.lastFetchProductID, product.id)
    }

    func testInitialFavoriteStateReflectsService() {
        let favorites = MockFavoritesService(initialIDs: [7])
        let viewModel = ProductDetailViewModel(
            productID: 7,
            productService: MockProductService(),
            favoritesService: favorites,
            imageBaseURL: URL(string: "https://api.example.com")!
        )
        XCTAssertTrue(viewModel.isFavorite)
    }
}
