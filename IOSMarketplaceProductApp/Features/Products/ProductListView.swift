import SwiftUI

struct ProductListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject var viewModel: ProductListViewModel

    var body: some View {
        Group {
            switch viewModel.listState {
            case .idle, .loading where viewModel.products.isEmpty:
                ProgressView("Loading catalog…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                EmptyStateView(
                    systemImage: "wifi.exclamationmark",
                    title: "Couldn’t load products",
                    message: message
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Retry") { viewModel.refresh() }
                    }
                }
            case .loaded, .loading:
                listContent
            }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if let total = viewModel.totalCount, total > 0 {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(total) items")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.marketplaceTextSecondary)
                }
            }
        }
        .refreshable { viewModel.refresh() }
        .onAppear { viewModel.onAppear() }
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
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: product)
                    }
                }
            } header: {
                Text("Curated for you")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.marketplaceTextSecondary)
                    .textCase(nil)
            } footer: {
                if viewModel.hasMorePages {
                    Text("Pull down to refresh · scroll for more")
                        .font(.footnote)
                        .foregroundStyle(Color.marketplaceTextSecondary)
                }
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
        .overlay(alignment: .bottom) {
            if let banner = viewModel.bannerError {
                ErrorBanner(message: banner) {
                    viewModel.bannerError = nil
                }
                .padding(MarketplaceSpacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.bannerError)
        .overlay {
            if viewModel.isLoadingMore {
                VStack {
                    Spacer()
                    ProgressView()
                        .padding(.horizontal, MarketplaceSpacing.md)
                        .padding(.vertical, MarketplaceSpacing.xs)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, MarketplaceSpacing.xl)
                }
            }
        }
    }
}
