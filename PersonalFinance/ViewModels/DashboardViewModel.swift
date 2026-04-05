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
    var isLoading = false

    private let transactionService = TransactionService()
    private let goalService = GoalService()

    // MARK: - Greeting

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
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

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmount }
    }

    // MARK: - Weekly Spending Chart

    var weeklySpending: [DailySpending] {
        let calendar = Calendar.current
        let startOfWeek = Date.now.startOfWeek

        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: startOfWeek) ?? .now

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

    // MARK: - Recent Transactions

    var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }

    // MARK: - Data Loading

    func loadData(context: ModelContext) {
        isLoading = true
        do {
            transactions = try transactionService.fetch(context: context)
            goals = try goalService.fetch(context: context)
        } catch {
            transactions = []
            goals = []
        }
        isLoading = false
    }
}
