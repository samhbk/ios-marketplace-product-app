import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject var viewModel: FavoritesViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading where viewModel.products.isEmpty:
                ProgressView("Loading favorites…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                EmptyStateView(
                    systemImage: "heart.slash",
                    title: "Couldn’t load favorites",
                    message: message
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Retry") { viewModel.load() }
                    }
                }
            case .loaded:
                if viewModel.products.isEmpty {
                    EmptyStateView(
                        systemImage: "heart",
                        title: "No favorites yet",
                        message: "Tap the heart on any product to save it here."
                    )
                } else {
                    listContent
                }
            case .loading:
                listContent
            }
        }
        .navigationTitle("Favorites")
        .refreshable { viewModel.load() }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.load()
            }
            viewModel.onAppear()
        }
        .safeAreaInset(edge: .bottom) {
            if let banner = viewModel.bannerError {
                ErrorBanner(message: banner) { viewModel.bannerError = nil }
                    .padding(MarketplaceSpacing.md)
            }
        }
        .marketplaceScreenBackground()
    }

    private var listContent: some View {
        List {
            Section {
                ForEach(viewModel.products) { product in
                    NavigationLink(value: product.id) {
                        ProductRowView(product: product, imageBaseURL: environment.configuration.baseURL)
                    }
                    .listRowInsets(EdgeInsets(
                        top: MarketplaceSpacing.xs,
                        leading: MarketplaceSpacing.md,
                        bottom: MarketplaceSpacing.xs,
                        trailing: MarketplaceSpacing.md
                    ))
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: MarketplaceRadius.lg, style: .continuous)
                            .fill(Color.marketplaceCard)
                            .padding(.vertical, MarketplaceSpacing.xxs)
                    )
                }
            } header: {
                Text("\(viewModel.products.count) saved items")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.marketplaceTextSecondary)
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Int.self) { id in
            ProductDetailView(
                viewModel: ProductDetailViewModel(
                    productID: id,
                    productService: environment.productService,
                    favoritesService: environment.favoritesService,
                    imageBaseURL: environment.configuration.baseURL
                )
            )
        }
    }
}
