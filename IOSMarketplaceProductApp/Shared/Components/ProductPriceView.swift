import SwiftUI

struct ProductPriceView: View {
    enum Style {
        case list
        case detail
    }

    let price: Decimal
    let compareAtPrice: Decimal?
    let currencyCode: String?
    var style: Style = .list

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: MarketplaceSpacing.xs) {
            Text(PriceFormatter.string(for: price, currencyCode: currencyCode))
                .font(priceFont)
                .foregroundStyle(Color.marketplaceAccent)

            if let compareAtPrice, compareAtPrice > price {
                Text(PriceFormatter.string(for: compareAtPrice, currencyCode: currencyCode))
                    .font(compareFont)
                    .foregroundStyle(Color.marketplaceTextSecondary)
                    .strikethrough()
            }

            if style == .detail, compareAtPrice != nil, let compareAtPrice, compareAtPrice > price {
                Text("Sale")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.marketplaceSale, in: Capsule())
            }
        }
    }

    private var priceFont: Font {
        switch style {
        case .list:
            return .subheadline.weight(.semibold)
        case .detail:
            return .title.weight(.bold)
        }
    }

    private var compareFont: Font {
        switch style {
        case .list:
            return .caption
        case .detail:
            return .subheadline
        }
    }
}
