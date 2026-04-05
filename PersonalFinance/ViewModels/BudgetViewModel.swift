import Foundation
import SwiftData
import SwiftUI

@Observable
final class BudgetViewModel {
    var budgets: [Budget] = []
    var transactions: [Transaction] = []
    var showingAddBudget: Bool = false
    var budgetToEdit: Budget? = nil

    // Add budget form state
    var selectedCategory: Category? = nil
    var limitText: String = ""

    private let budgetService = BudgetService()
    private let transactionService = TransactionService()

    // MARK: - Computed

    var limitValue: Double {
        Double(limitText) ?? 0
    }

    var isAddValid: Bool {
        selectedCategory != nil && limitValue > 0
    }

    // MARK: - Aggregate

    var totalLimit: Double {
        budgets.reduce(0) { $0 + $1.monthlyLimit }
    }

    var totalSpent: Double {
        budgets.reduce(0) { total, budget in total + spentFor(budget) }
    }

    var totalRemaining: Double {
        max(totalLimit - totalSpent, 0)
    }

    var totalUsagePercent: Double {
        guard totalLimit > 0 else { return 0 }
        return totalSpent / totalLimit
    }

    var overallStatusColor: Color {
        let pct = totalUsagePercent
        if pct >= 1.0 { return .expenseRed }
        if pct >= 0.8 { return .orange }
        return .incomeGreen
    }

    var needsAttentionBudgets: [Budget] {
        budgets.filter { budget in
            let ratio = budget.monthlyLimit > 0 ? spentFor(budget) / budget.monthlyLimit : 0
            return ratio >= 0.8
        }
    }

    // MARK: - Methods

    func loadData(context: ModelContext) {
        do {
            budgets = try budgetService.fetchBudgets(context: context)
            transactions = try transactionService.fetch(context: context)
        } catch {
            budgets = []
            transactions = []
        }
    }

    func spentFor(_ budget: Budget) -> Double {
        budgetService.spentForCategory(budget.category, month: budget.month, transactions: transactions)
    }

    func addBudget(context: ModelContext) {
        guard let category = selectedCategory, limitValue > 0 else { return }
        let budget = Budget(category: category, monthlyLimit: limitValue)
        budgetService.add(budget, context: context)
        selectedCategory = nil
        limitText = ""
        loadData(context: context)
    }

    func deleteBudget(_ budget: Budget, context: ModelContext) {
        budgetService.delete(budget, context: context)
        loadData(context: context)
    }

    func startEditing(_ budget: Budget) {
        budgetToEdit = budget
        selectedCategory = budget.category
        limitText = String(format: "%.0f", budget.monthlyLimit)
    }

    func updateBudget(context: ModelContext) {
        guard let budget = budgetToEdit, limitValue > 0 else { return }
        budgetService.update(budget, monthlyLimit: limitValue)
        try? context.save()
        budgetToEdit = nil
        selectedCategory = nil
        limitText = ""
        loadData(context: context)
    }
}
