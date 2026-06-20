import Combine
import XCTest
@testable import IOSMarketplaceProductApp

@MainActor
final class ProductListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testRefreshLoadsFirstPage() {
        let service = MockProductService()
        let product = TestFixtures.sampleProduct
        service.fetchProductsResult = .success(TestFixtures.paginated(products: [product], currentPage: 1, lastPage: 1))

        let viewModel = ProductListViewModel(productService: service, perPage: 20)
        let expectation = expectation(description: "products loaded")

        viewModel.$listState
            .dropFirst()
            .sink { state in
                if case .loaded = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.refresh()
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.products.first?.id, product.id)
        XCTAssertEqual(service.lastFetchProductsPage, 1)
    }

    func testRefreshFailureSetsFailedState() {
        let service = MockProductService()
        service.fetchProductsResult = .failure(.server(status: 500, message: "Server down"))

        let viewModel = ProductListViewModel(productService: service)
        let expectation = expectation(description: "failed state")

        viewModel.$listState
            .dropFirst()
            .sink { state in
                if case .failed(let message) = state, message == "Server down" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.refresh()
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.products.isEmpty)
    }

    func testLoadMoreAppendsNextPage() {
        let service = MockProductService()
        let pageOne = Product(id: 1, name: "A", description: nil, price: 1, currencyCode: "EUR", imageURL: nil, category: nil)
        let pageTwo = Product(id: 2, name: "B", description: nil, price: 2, currencyCode: "EUR", imageURL: nil, category: nil)

        service.fetchProductsResult = .success(TestFixtures.paginated(products: [pageOne], currentPage: 1, lastPage: 2))

        let viewModel = ProductListViewModel(productService: service, perPage: 1)
        let firstLoad = expectation(description: "first page")
        viewModel.$listState
            .dropFirst()
            .sink { state in
                if case .loaded = state, viewModel.products.count == 1 {
                    firstLoad.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.refresh()
        wait(for: [firstLoad], timeout: 2)

        service.fetchProductsResult = .success(TestFixtures.paginated(products: [pageTwo], currentPage: 2, lastPage: 2))
        let secondLoad = expectation(description: "second page")
        viewModel.$products
            .dropFirst()
            .sink { products in
                if products.count == 2 {
                    secondLoad.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadMoreIfNeeded(currentItem: pageOne)
        wait(for: [secondLoad], timeout: 2)
        XCTAssertEqual(viewModel.products.map(\.id), [1, 2])
    }
}
