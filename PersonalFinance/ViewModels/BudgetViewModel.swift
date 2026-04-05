import Foundation
import SwiftData

@Observable
final class BudgetViewModel {
    var budgets: [Budget] = []
    var transactions: [Transaction] = []
    var showingAddBudget: Bool = false

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
}
