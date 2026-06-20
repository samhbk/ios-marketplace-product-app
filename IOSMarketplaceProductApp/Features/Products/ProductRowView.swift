import SwiftUI

struct ProductRowView: View {
    let product: Product
    let imageBaseURL: URL

    var body: some View {
        HStack(alignment: .top, spacing: MarketplaceSpacing.sm + 2) {
            MarketplaceAsyncImage(
                url: product.resolvedImageURL(relativeTo: imageBaseURL),
                cornerRadius: MarketplaceRadius.md,
                showBorder: true
            )
            .frame(width: 92, height: 92)
            .overlay(alignment: .topLeading) {
                if product.isOnSale {
                    Text("SALE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.marketplaceSale, in: Capsule())
                        .padding(6)
                }
            }

            VStack(alignment: .leading, spacing: MarketplaceSpacing.xs) {
                if let category = product.category {
                    CategoryBadge(title: category)
                }

                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let description = product.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.marketplaceTextSecondary)
                        .lineLimit(2)
                        .lineSpacing(2)
                }

                ProductPriceView(
                    price: product.price,
                    compareAtPrice: product.compareAtPrice,
                    currencyCode: product.currencyCode,
                    style: .list
                )
                .padding(.top, MarketplaceSpacing.xxs)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, MarketplaceSpacing.xxs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
