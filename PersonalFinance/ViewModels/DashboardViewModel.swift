import Foundation
import SwiftData

struct DailySpending: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let amount: Double
    let isToday: Bool
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
    let percentage: Double
}

@Observable
final class DashboardViewModel {
    var transactions: [Transaction] = []
    var goals: [SavingsGoal] = []
    var budgets: [Budget] = []
    var isLoading = false
    var errorMessage: String?

    private let transactionService = TransactionService()
    private let goalService = GoalService()
    private let budgetService = BudgetService()

    // MARK: - Greeting

    func greeting(for userName: String) -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        case 17..<22: timeGreeting = "Good evening"
        default: timeGreeting = "Good night"
        }

        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return timeGreeting
        }
        return "\(timeGreeting), \(trimmed)"
    }

    // MARK: - Monthly Totals

    var monthlyIncome: Double {
        transactions
            .filter { $0.type == .income && $0.date.isThisMonth }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyExpenses: Double {
        transactions
            .filter { $0.type == .expense && $0.date.isThisMonth }
            .reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        monthlyIncome - monthlyExpenses
    }

    var leftToSpend: Double {
        monthlyIncome - monthlyExpenses
    }

    // MARK: - Budget Health

    var totalBudgetLimit: Double {
        budgets.reduce(0) { $0 + $1.monthlyLimit }
    }

    var totalBudgetSpent: Double {
        budgets.reduce(0) { total, budget in
            total + budgetService.spentForCategory(budget.category, month: .now, transactions: transactions)
        }
    }

    var budgetUsagePercent: Double {
        guard totalBudgetLimit > 0 else { return 0 }
        return totalBudgetSpent / totalBudgetLimit
    }

    var hasBudgets: Bool {
        !budgets.isEmpty
    }

    // MARK: - Weekly Spending Chart (Rolling 7 days)

    var weeklySpending: [DailySpending] {
        let calendar = Calendar.current

        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: -(6 - offset), to: .now.startOfDay) ?? .now

            let dayExpenses = transactions
                .filter { $0.type == .expense && calendar.isDate($0.date, inSameDayAs: dayDate) }
                .reduce(0.0) { $0 + $1.amount }

            let dayAbbreviation = dayDate.formatted(.dateTime.weekday(.abbreviated))

            return DailySpending(
                day: dayAbbreviation,
                date: dayDate,
                amount: dayExpenses,
                isToday: dayDate.isToday
            )
        }
    }

    // MARK: - Category Breakdown

    var categoryBreakdown: [CategorySpending] {
        let monthExpenses = transactions.filter { $0.type == .expense && $0.date.isThisMonth }
        guard !monthExpenses.isEmpty else { return [] }

        let totalExpenses = monthExpenses.reduce(0.0) { $0 + $1.amount }
        guard totalExpenses > 0 else { return [] }

        let grouped = Dictionary(grouping: monthExpenses) { $0.category }
        let sorted = grouped
            .map { (category: $0.key, total: $0.value.reduce(0.0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }

        var result: [CategorySpending] = []
        let topCategories = Array(sorted.prefix(5))
        let otherTotal = sorted.dropFirst(5).reduce(0.0) { $0 + $1.total }

        for item in topCategories {
            result.append(CategorySpending(
                category: item.category,
                amount: item.total,
                percentage: item.total / totalExpenses
            ))
        }

        if otherTotal > 0 {
            result.append(CategorySpending(
                category: .other,
                amount: otherTotal,
                percentage: otherTotal / totalExpenses
            ))
        }

        return result
    }

    var totalMonthlyExpenses: Double {
        monthlyExpenses
    }

    // MARK: - Recent Transactions

    var recentTransactions: [Transaction] {
        Array(transactions.prefix(3))
    }

    // MARK: - Data Loading

    func loadData(context: ModelContext) {
        isLoading = true
        errorMessage = nil
        do {
            transactions = try transactionService.fetch(context: context)
            goals = try goalService.fetch(context: context)
            budgets = try budgetService.fetchBudgets(context: context)
        } catch {
            transactions = []
            goals = []
            budgets = []
            errorMessage = "Couldn't load your data. Tap to retry."
        }
        isLoading = false
    }
}
