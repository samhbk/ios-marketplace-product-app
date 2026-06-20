import SwiftUI

struct CategoryBadge: View {
    enum Style {
        case inline
        case overlay
    }

    let title: String
    var style: Style = .inline

    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .foregroundStyle(foreground)
            .padding(.horizontal, style == .overlay ? 10 : 8)
            .padding(.vertical, style == .overlay ? 6 : 4)
            .background(backgroundColor, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .inline:
            return .marketplaceAccent
        case .overlay:
            return .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .inline:
            return .marketplaceAccentMuted
        case .overlay:
            return .black.opacity(0.55)
        }
    }
}
