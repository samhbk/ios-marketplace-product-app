import SwiftUI
import UIKit

extension Color {
    /// Primary brand — confident blue-violet tuned for commerce UI.
    static let marketplaceAccent = Color(red: 0.09, green: 0.40, blue: 0.92)
    static let marketplaceAccentMuted = Color(red: 0.09, green: 0.40, blue: 0.92).opacity(0.14)

    static let marketplaceBackground = Color(uiColor: .systemGroupedBackground)
    static let marketplaceCard = Color(uiColor: .secondarySystemGroupedBackground)
    static let marketplaceSurface = Color(uiColor: .tertiarySystemGroupedBackground)
    static let marketplaceBorder = Color(uiColor: .separator).opacity(0.6)

    static let marketplaceSale = Color(red: 0.91, green: 0.22, blue: 0.28)
    static let marketplaceSuccess = Color(red: 0.13, green: 0.64, blue: 0.42)
    static let marketplaceTextSecondary = Color(uiColor: .secondaryLabel)
}
