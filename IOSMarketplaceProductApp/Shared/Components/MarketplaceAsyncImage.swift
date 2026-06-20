import SwiftUI

/// Cached `AsyncImage` with placeholder and failure state; uses shared `URLCache`.
struct MarketplaceAsyncImage: View {
    let url: URL?
    private let cornerRadius: CGFloat
    private let showBorder: Bool

    init(url: URL?, cornerRadius: CGFloat = MarketplaceRadius.sm, showBorder: Bool = false) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
    }

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        failure
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                failure
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.marketplaceBorder, lineWidth: 0.5)
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.marketplaceSurface
            ProgressView()
                .tint(.marketplaceAccent)
        }
    }

    private var failure: some View {
        ZStack {
            Color.marketplaceSurface
            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(Color.marketplaceTextSecondary)
        }
    }
}
