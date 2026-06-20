import SwiftUI

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: MarketplaceSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.marketplaceTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(MarketplaceSpacing.sm)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: MarketplaceRadius.sm, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
