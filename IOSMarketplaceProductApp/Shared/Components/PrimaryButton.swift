import SwiftUI

struct PrimaryButton: View {
    enum Variant {
        case primary
        case favoriteSaved
        case secondary
    }

    let title: String
    let systemImage: String?
    let isBusy: Bool
    let variant: Variant
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        isBusy: Bool = false,
        variant: Variant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isBusy = isBusy
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: MarketplaceSpacing.xs) {
                if isBusy {
                    ProgressView()
                        .tint(foregroundColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MarketplaceSpacing.sm + 2)
            .foregroundStyle(foregroundColor)
            .background(background, in: RoundedRectangle(cornerRadius: MarketplaceRadius.md, style: .continuous))
            .overlay {
                if variant == .secondary || variant == .favoriteSaved {
                    RoundedRectangle(cornerRadius: MarketplaceRadius.md, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                }
            }
        }
        .disabled(isBusy)
        .accessibilityLabel(title)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return .white
        case .favoriteSaved:
            return .marketplaceSuccess
        case .secondary:
            return .marketplaceAccent
        }
    }

    private var background: some ShapeStyle {
        switch variant {
        case .primary:
            return AnyShapeStyle(Color.marketplaceAccent)
        case .favoriteSaved:
            return AnyShapeStyle(Color.marketplaceSuccess.opacity(0.12))
        case .secondary:
            return AnyShapeStyle(Color.marketplaceCard)
        }
    }

    private var borderColor: Color {
        switch variant {
        case .favoriteSaved:
            return .marketplaceSuccess.opacity(0.35)
        case .secondary:
            return .marketplaceAccent.opacity(0.35)
        case .primary:
            return .clear
        }
    }
}
