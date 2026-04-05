import Foundation
import SwiftData

@Observable
final class GoalsListViewModel {
    var goals: [SavingsGoal] = []
    var isLoading = false
    var showingAddGoal: Bool = false

    private let goalService = GoalService()

    var activeGoals: [SavingsGoal] {
        goals.filter { !$0.isCompleted }
    }

    var completedGoals: [SavingsGoal] {
        goals.filter { $0.isCompleted }
    }

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    var overallProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return min(totalSaved / totalTarget, 1.0)
    }

    func loadGoals(context: ModelContext) {
        isLoading = true
        do {
            goals = try goalService.fetch(context: context)
        } catch {
            goals = []
        }
        isLoading = false
    }

    func deleteGoal(_ goal: SavingsGoal, context: ModelContext) {
        goalService.delete(goal, context: context)
        loadGoals(context: context)
    }
}
