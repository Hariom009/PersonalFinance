import SwiftUI

// MARK: - App Font Styles

enum AppFont {
    case largeAmount    // Large monetary displays (40pt rounded)
    case amount         // Standard monetary amounts (32pt rounded)
    case heading        // Section/screen headings (title3, 20pt bold)
    case sectionTitle   // Section headers (headline, 17pt semibold)
    case bodyText       // Primary readable text (body, 17pt)
    case label          // Secondary content labels (subheadline, 15pt)
    case smallLabel     // Tertiary labels (footnote, 13pt)
    case caption        // Timestamps, badges, minor info (caption, 12pt)
    case miniCaption    // Smallest allowed text (11pt) — nothing smaller

    var font: Font {
        switch self {
        case .largeAmount:
            return .system(size: 40, weight: .bold, design: .rounded)
        case .amount:
            return .system(size: 32, weight: .bold, design: .rounded)
        case .heading:
            return .system(.title3, design: .default).bold()
        case .sectionTitle:
            return .system(.headline)
        case .bodyText:
            return .system(.body)
        case .label:
            return .system(.subheadline)
        case .smallLabel:
            return .system(.footnote)
        case .caption:
            return .system(.caption)
        case .miniCaption:
            return .system(size: 11)
        }
    }
}

// MARK: - App Spacing

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

// MARK: - App Sizes

enum AppSize {
    // Icons
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24

    // Tap targets
    static let tapTarget: CGFloat = 44

    // Card padding
    static let cardPadding: CGFloat = 16

    // Icon containers
    static let iconContainerSmall: CGFloat = 36
    static let iconContainerMedium: CGFloat = 40
    static let iconContainerLarge: CGFloat = 48
}
