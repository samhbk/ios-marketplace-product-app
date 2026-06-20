import Combine
import Foundation

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var loadState: LoadState = .idle
    @Published var isFavorite: Bool
    @Published var bannerError: String?
    @Published private(set) var favoriteBusy: Bool = false

    private let productID: Int
    private let productService: ProductServicing
    private let favoritesService: FavoritesServicing
    private let imageBaseURL: URL
    private var cancellables = Set<AnyCancellable>()
    private var loadCancellable: AnyCancellable?
    private var favoriteCancellable: AnyCancellable?

    init(
        productID: Int,
        productService: ProductServicing,
        favoritesService: FavoritesServicing,
        imageBaseURL: URL
    ) {
        self.productID = productID
        self.productService = productService
        self.favoritesService = favoritesService
        self.imageBaseURL = imageBaseURL
        self.isFavorite = favoritesService.isFavorite(productID: productID)

        favoritesService.favoriteIDsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                guard let self else { return }
                isFavorite = ids.contains(productID)
            }
            .store(in: &cancellables)
    }

    var resolvedImageURL: URL? {
        product?.resolvedImageURL(relativeTo: imageBaseURL)
    }

    func load() {
        loadCancellable?.cancel()
        loadState = .loading
        bannerError = nil
        loadCancellable = productService
            .fetchProduct(id: productID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.loadState = .failed(error.userMessage)
                }
            } receiveValue: { [weak self] product in
                guard let self else { return }
                self.product = product
                loadState = .loaded
            }
    }

    func toggleFavorite() {
        favoriteCancellable?.cancel()
        favoriteBusy = true
        bannerError = nil
        favoriteCancellable = favoritesService
            .toggleFavorite(productID: productID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.favoriteBusy = false
                if case .failure(let error) = completion {
                    self?.bannerError = error.userMessage
                }
            } receiveValue: { _ in }
    }
}
