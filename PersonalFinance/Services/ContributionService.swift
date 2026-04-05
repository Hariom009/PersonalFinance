import Foundation
import SwiftData

struct ContributionService {
    func addFunds(to goal: SavingsGoal, amount: Double, note: String = "", context: ModelContext) {
        let contribution = GoalContribution(
            goalId: goal.id,
            amount: amount,
            note: note
        )
        context.insert(contribution)
        goal.currentAmount += amount
        try? context.save()
    }

    func deleteContribution(_ contribution: GoalContribution, from goal: SavingsGoal, context: ModelContext) {
        goal.currentAmount = max(0, goal.currentAmount - contribution.amount)
        context.delete(contribution)
        try? context.save()
    }

    func fetchContributions(for goalId: UUID, context: ModelContext) throws -> [GoalContribution] {
        let descriptor = FetchDescriptor<GoalContribution>(
            predicate: #Predicate<GoalContribution> { $0.goalId == goalId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
