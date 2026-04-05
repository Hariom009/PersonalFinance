import Foundation
import SwiftData

@Model
final class Transaction: Identifiable {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var category: Category
    var date: Date
    var note: String
    var isRecurring: Bool

    init(
        id: UUID = UUID(),
        amount: Double,
        type: TransactionType,
        category: Category,
        date: Date = .now,
        note: String = "",
        isRecurring: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
    }
}
