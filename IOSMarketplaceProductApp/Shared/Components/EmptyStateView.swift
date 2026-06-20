import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: MarketplaceSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.marketplaceAccentMuted)
                    .frame(width: 72, height: 72)
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.marketplaceAccent)
            }

            Text(title)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            if !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.marketplaceTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(MarketplaceSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
