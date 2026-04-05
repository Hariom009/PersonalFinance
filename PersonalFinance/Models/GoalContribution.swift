import Foundation
import SwiftData

@Model
final class GoalContribution: Identifiable {
    var id: UUID
    var goalId: UUID
    var amount: Double
    var date: Date
    var note: String

    init(
        id: UUID = UUID(),
        goalId: UUID,
        amount: Double,
        date: Date = .now,
        note: String = ""
    ) {
        self.id = id
        self.goalId = goalId
        self.amount = amount
        self.date = date
        self.note = note
    }
}
