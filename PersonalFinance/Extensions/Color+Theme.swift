import SwiftUI

extension ShapeStyle where Self == Color {
    static var appPrimary: Color { .blue }
    static var appSecondary: Color { .indigo }
    static var incomeGreen: Color { .green }
    static var expenseRed: Color { .red }
    static var appBackground: Color { Color(.systemGroupedBackground) }
    static var cardBackground: Color { Color(.secondarySystemGroupedBackground) }
}
