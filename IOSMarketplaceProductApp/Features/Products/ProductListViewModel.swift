import Combine
import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var listState: LoadState = .idle
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var totalCount: Int?
    @Published var bannerError: String?

    var hasMorePages: Bool { hasMore }

    private let productService: ProductServicing
    private let perPage: Int
    private var currentPage: Int = 1
    private var hasMore: Bool = true
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: AnyCancellable?

    init(productService: ProductServicing, perPage: Int = 20) {
        self.productService = productService
        self.perPage = perPage
    }

    func onAppear() {
        if case .idle = listState {
            refresh()
        }
    }

    func refresh() {
        loadTask?.cancel()
        currentPage = 1
        hasMore = true
        totalCount = nil
        listState = .loading
        bannerError = nil
        loadPage(reset: true)
    }

    func loadMoreIfNeeded(currentItem: Product?) {
        guard let currentItem else { return }
        guard hasMore, !isLoadingMore, case .loaded = listState else { return }
        guard let idx = products.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = max(products.count - 5, 0)
        if idx >= threshold {
            loadPage(reset: false)
        }
    }

    private func loadPage(reset: Bool) {
        if reset {
            loadTask?.cancel()
        } else {
            guard !isLoadingMore else { return }
            isLoadingMore = true
        }

        let page = reset ? 1 : currentPage + 1
        loadTask = productService
            .fetchProducts(page: page, perPage: perPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isLoadingMore = false
                if case .failure(let error) = completion {
                    if reset {
                        listState = .failed(error.userMessage)
                    } else {
                        bannerError = error.userMessage
                    }
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                if reset {
                    products = page.data
                    listState = .loaded
                    totalCount = page.meta?.total ?? page.data.count
                } else {
                    let existing = Set(products.map(\.id))
                    let merged = page.data.filter { !existing.contains($0.id) }
                    products.append(contentsOf: merged)
                }
                currentPage = page.currentPage
                hasMore = page.hasMorePages
            }
    }
}
