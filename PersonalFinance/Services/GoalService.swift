import Foundation
import SwiftData

struct GoalService {
    func add(_ goal: SavingsGoal, context: ModelContext) {
        context.insert(goal)
    }

    func delete(_ goal: SavingsGoal, context: ModelContext) {
        context.delete(goal)
    }

    func update(
        _ goal: SavingsGoal,
        name: String? = nil,
        targetAmount: Double? = nil,
        currentAmount: Double? = nil,
        deadline: Date? = nil,
        iconName: String? = nil
    ) {
        if let name { goal.name = name }
        if let targetAmount { goal.targetAmount = targetAmount }
        if let currentAmount { goal.currentAmount = currentAmount }
        if let deadline { goal.deadline = deadline }
        if let iconName { goal.iconName = iconName }
    }

    func fetch(context: ModelContext) throws -> [SavingsGoal] {
        let descriptor = FetchDescriptor<SavingsGoal>(
            sortBy: [SortDescriptor(\.deadline, order: .forward)]
        )
        return try context.fetch(descriptor)
    }
}
