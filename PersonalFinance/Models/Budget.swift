import Foundation
import SwiftData

@Model
final class Budget: Identifiable {
    var id: UUID
    var categoryRaw: String
    var monthlyLimit: Double
    var month: Date

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        category: Category,
        monthlyLimit: Double,
        month: Date = Date.now.startOfMonth
    ) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.monthlyLimit = monthlyLimit
        self.month = month
    }
}
