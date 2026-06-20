import SwiftUI

struct ProductDetailView: View {
    @StateObject var viewModel: ProductDetailViewModel

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading where viewModel.product == nil:
                ProgressView("Loading product…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                EmptyStateView(
                    systemImage: "exclamationmark.triangle",
                    title: "Something went wrong",
                    message: message
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Retry") { viewModel.load() }
                    }
                }
            case .loaded, .loading:
                if let product = viewModel.product {
                    content(product: product)
                } else {
                    EmptyStateView(systemImage: "cube", title: "Missing product", message: "")
                }
            }
        }
        .navigationTitle(viewModel.product?.name ?? "Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.marketplaceBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            viewModel.isFavorite ? Color.marketplaceSale : Color.marketplaceTextSecondary,
                            viewModel.isFavorite ? Color.marketplaceSale.opacity(0.25) : Color.clear
                        )
                }
                .disabled(viewModel.favoriteBusy)
                .accessibilityLabel(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .onAppear { if viewModel.product == nil { viewModel.load() } }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .background(Color.marketplaceBackground)
    }

    @ViewBuilder
    private var bottomBar: some View {
        if viewModel.product != nil {
            VStack(spacing: MarketplaceSpacing.xs) {
                if let banner = viewModel.bannerError {
                    ErrorBanner(message: banner) { viewModel.bannerError = nil }
                        .padding(.horizontal, MarketplaceSpacing.md)
                }

                Group {
                    if viewModel.isFavorite {
                        PrimaryButton(
                            title: "Saved to favorites",
                            systemImage: "checkmark.circle.fill",
                            isBusy: viewModel.favoriteBusy,
                            variant: .favoriteSaved
                        ) {
                            viewModel.toggleFavorite()
                        }
                    } else {
                        PrimaryButton(
                            title: "Add to favorites",
                            systemImage: "heart.fill",
                            isBusy: viewModel.favoriteBusy
                        ) {
                            viewModel.toggleFavorite()
                        }
                    }
                }
                .padding(.horizontal, MarketplaceSpacing.md)
                .padding(.top, MarketplaceSpacing.sm)
                .padding(.bottom, MarketplaceSpacing.xs)
            }
            .background {
                Rectangle()
                    .fill(.bar)
                    .overlay(alignment: .top) {
                        Divider()
                    }
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private func content(product: Product) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: MarketplaceSpacing.lg) {
                heroImage(product: product)

                VStack(alignment: .leading, spacing: MarketplaceSpacing.md) {
                    ProductPriceView(
                        price: product.price,
                        compareAtPrice: product.compareAtPrice,
                        currencyCode: product.currencyCode,
                        style: .detail
                    )

                    if let description = product.description, !description.isEmpty {
                        Divider()
                            .padding(.vertical, MarketplaceSpacing.xxs)

                        VStack(alignment: .leading, spacing: MarketplaceSpacing.sm) {
                            Text("About this item")
                                .font(.headline)

                            Text(description)
                                .font(.body)
                                .foregroundStyle(Color.marketplaceTextSecondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .marketplaceCard()
                .padding(.horizontal, MarketplaceSpacing.md)
            }
            .padding(.top, MarketplaceSpacing.md)
            .padding(.bottom, MarketplaceSpacing.xxl)
        }
        .background(Color.marketplaceBackground)
    }

    private func heroImage(product: Product) -> some View {
        MarketplaceAsyncImage(url: viewModel.resolvedImageURL, cornerRadius: MarketplaceRadius.xl, showBorder: true)
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .overlay(alignment: .bottomLeading) {
                if let category = product.category {
                    CategoryBadge(title: category, style: .overlay)
                        .padding(MarketplaceSpacing.md)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if product.isOnSale {
                    Text("SALE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.marketplaceSale, in: Capsule())
                        .padding(MarketplaceSpacing.md)
                }
            }
            .padding(.horizontal, MarketplaceSpacing.md)
    }
}
