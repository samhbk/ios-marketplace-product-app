import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var state: LoadState = .idle
    @Published var bannerError: String?

    private let favoritesService: FavoritesServicing
    private let productService: ProductServicing
    private var cancellables = Set<AnyCancellable>()

    init(favoritesService: FavoritesServicing, productService: ProductServicing) {
        self.favoritesService = favoritesService
        self.productService = productService

        favoritesService.favoriteIDsPublisher
            .dropFirst()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadSilently()
            }
            .store(in: &cancellables)
    }

    func load() {
        state = .loading
        bannerError = nil
        favoritesService
            .fetchFavoriteProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .failed(error.userMessage)
                }
            } receiveValue: { [weak self] items in
                guard let self else { return }
                products = items
                state = .loaded
            }
            .store(in: &cancellables)
    }

    private func reloadSilently() {
        favoritesService
            .fetchFavoriteProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.bannerError = error.userMessage
                }
            } receiveValue: { [weak self] items in
                self?.products = items
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        favoritesService
            .syncFromServer()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
