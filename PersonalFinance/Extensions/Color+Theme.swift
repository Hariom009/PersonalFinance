import SwiftUI

extension ShapeStyle where Self == Color {
    static var appPrimary: Color { Color(hex: "B99FF8") }
    static var appSecondary: Color { Color(hex: "9B7BE8") }
    static var incomeGreen: Color { .green }
    static var expenseRed: Color { .red }
    static var appBackground: Color { Color(.systemGroupedBackground) }
    static var cardBackground: Color { Color(.secondarySystemGroupedBackground) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
