import Foundation
import SwiftData

@Observable
final class GoalDetailViewModel {
    let goal: SavingsGoal
    var contributions: [GoalContribution] = []
    var showingAddFunds: Bool = false
    var showingEditGoal: Bool = false
    var fundsAmount: String = ""
    var fundsNote: String = ""

    private let contributionService = ContributionService()
    private let goalService = GoalService()

    init(goal: SavingsGoal) {
        self.goal = goal
    }

    // MARK: - Computed

    var daysRemaining: Int {
        let days = Calendar.current.dateComponents([.day], from: .now, to: goal.deadline).day ?? 0
        return max(days, 0)
    }

    var remainingAmount: Double {
        max(goal.targetAmount - goal.currentAmount, 0)
    }

    var dailyTarget: Double {
        guard daysRemaining > 0 else { return remainingAmount }
        return remainingAmount / Double(daysRemaining)
    }

    var fundsAmountValue: Double {
        Double(fundsAmount) ?? 0
    }

    var isFundsValid: Bool {
        fundsAmountValue > 0
    }

    // MARK: - Methods

    func loadContributions(context: ModelContext) {
        do {
            contributions = try contributionService.fetchContributions(for: goal.id, context: context)
        } catch {
            contributions = []
        }
    }

    func addFunds(context: ModelContext) {
        guard isFundsValid else { return }
        contributionService.addFunds(to: goal, amount: fundsAmountValue, note: fundsNote, context: context)
        fundsAmount = ""
        fundsNote = ""
        loadContributions(context: context)
    }

    func deleteContribution(_ contribution: GoalContribution, context: ModelContext) {
        contributionService.deleteContribution(contribution, from: goal, context: context)
        loadContributions(context: context)
    }

    func deleteGoal(context: ModelContext) {
        goalService.delete(goal, context: context)
    }
}
