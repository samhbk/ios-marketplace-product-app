import SwiftUI

enum MarketplaceSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum MarketplaceRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 18
    static let xl: CGFloat = 22
}

struct MarketplaceScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.marketplaceBackground.ignoresSafeArea())
    }
}

struct MarketplaceCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(MarketplaceSpacing.md)
            .background(Color.marketplaceCard, in: RoundedRectangle(cornerRadius: MarketplaceRadius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

extension View {
    func marketplaceScreenBackground() -> some View {
        modifier(MarketplaceScreenBackground())
    }

    func marketplaceCard() -> some View {
        modifier(MarketplaceCard())
    }
}
