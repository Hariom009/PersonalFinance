import Foundation
import SwiftData

struct WeeklyComparison {
    let thisWeek: [DailySpending]
    let lastWeek: [DailySpending]
    let thisWeekTotal: Double
    let lastWeekTotal: Double
    let percentChange: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expenses: Double
}

struct TopCategoryInsight {
    let category: Category
    let amount: Double
    let lastMonthAmount: Double
    let percentChange: Double
}

struct CategoryRank: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
}

struct QuickStats {
    let averageDailySpend: Double
    let mostFrequentCategory: Category?
    let biggestExpense: Transaction?
    let daysSinceLastIncome: Int
}

@Observable
final class InsightsViewModel {
    var transactions: [Transaction] = []
    var isLoading = false

    private let transactionService = TransactionService()

    // MARK: - Top Category

    var topCategory: TopCategoryInsight? {
        let calendar = Calendar.current
        let thisMonthStart = Date.now.startOfMonth

        let thisMonthExpenses = transactions.filter { $0.type == .expense && $0.date.isThisMonth }
        guard !thisMonthExpenses.isEmpty else { return nil }

        let grouped = Dictionary(grouping: thisMonthExpenses) { $0.category }
        let categoryTotals = grouped.map { (category: $0.key, total: $0.value.reduce(0.0) { $0 + $1.amount }) }
        guard let top = categoryTotals.max(by: { $0.total < $1.total }) else { return nil }

        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? thisMonthStart
        let lastMonthAmount = transactions
            .filter { $0.type == .expense && $0.category == top.category && $0.date >= lastMonthStart && $0.date < thisMonthStart }
            .reduce(0.0) { $0 + $1.amount }

        let change = lastMonthAmount > 0 ? ((top.total - lastMonthAmount) / lastMonthAmount) * 100 : 0

        return TopCategoryInsight(
            category: top.category,
            amount: top.total,
            lastMonthAmount: lastMonthAmount,
            percentChange: change
        )
    }

    // MARK: - Weekly Comparison

    var weeklyComparison: WeeklyComparison {
        let calendar = Calendar.current
        let thisWeekStart = Date.now.startOfWeek
        let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: thisWeekStart) ?? thisWeekStart

        let thisWeek = buildWeekSpending(from: thisWeekStart, calendar: calendar)
        let lastWeek = buildWeekSpending(from: lastWeekStart, calendar: calendar)

        let thisTotal = thisWeek.reduce(0.0) { $0 + $1.amount }
        let lastTotal = lastWeek.reduce(0.0) { $0 + $1.amount }
        let change = lastTotal > 0 ? ((thisTotal - lastTotal) / lastTotal) * 100 : 0

        return WeeklyComparison(
            thisWeek: thisWeek,
            lastWeek: lastWeek,
            thisWeekTotal: thisTotal,
            lastWeekTotal: lastTotal,
            percentChange: change
        )
    }

    private func buildWeekSpending(from start: Date, calendar: Calendar) -> [DailySpending] {
        (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: start) ?? .now
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

    // MARK: - Monthly Trend

    var monthlyTrend: [MonthlyData] {
        let calendar = Calendar.current
        let currentMonthStart = Date.now.startOfMonth

        return (0..<6).reversed().map { offset in
            let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart) ?? currentMonthStart
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? currentMonthStart

            let monthIncome = transactions
                .filter { $0.type == .income && $0.date >= monthStart && $0.date < monthEnd }
                .reduce(0.0) { $0 + $1.amount }

            let monthExpenses = transactions
                .filter { $0.type == .expense && $0.date >= monthStart && $0.date < monthEnd }
                .reduce(0.0) { $0 + $1.amount }

            let label = monthStart.formatted(.dateTime.month(.abbreviated))

            return MonthlyData(month: label, income: monthIncome, expenses: monthExpenses)
        }
    }

    // MARK: - Category Ranking

    var categoryRanking: [CategoryRank] {
        let monthExpenses = transactions.filter { $0.type == .expense && $0.date.isThisMonth }
        guard !monthExpenses.isEmpty else { return [] }

        let grouped = Dictionary(grouping: monthExpenses) { $0.category }
        return grouped
            .map { CategoryRank(category: $0.key, amount: $0.value.reduce(0.0) { $0 + $1.amount }) }
            .sorted { $0.amount > $1.amount }
    }

    // MARK: - Quick Stats

    var quickStats: QuickStats {
        let calendar = Calendar.current
        let dayOfMonth = max(calendar.component(.day, from: .now), 1)

        let monthExpenses = transactions.filter { $0.type == .expense && $0.date.isThisMonth }
        let totalExpenses = monthExpenses.reduce(0.0) { $0 + $1.amount }
        let averageDaily = totalExpenses / Double(dayOfMonth)

        let categoryCounts = Dictionary(grouping: monthExpenses) { $0.category }
            .mapValues { $0.count }
        let mostFrequent = categoryCounts.max(by: { $0.value < $1.value })?.key

        let biggestExpense = monthExpenses.max(by: { $0.amount < $1.amount })

        let lastIncome = transactions.first(where: { $0.type == .income })
        let daysSinceIncome: Int
        if let lastIncome {
            daysSinceIncome = calendar.dateComponents([.day], from: lastIncome.date.startOfDay, to: Date.now.startOfDay).day ?? 0
        } else {
            daysSinceIncome = 0
        }

        return QuickStats(
            averageDailySpend: averageDaily,
            mostFrequentCategory: mostFrequent,
            biggestExpense: biggestExpense,
            daysSinceLastIncome: daysSinceIncome
        )
    }

    // MARK: - Load

    func loadData(context: ModelContext) {
        isLoading = true
        do {
            transactions = try transactionService.fetch(context: context)
        } catch {
            transactions = []
        }
        isLoading = false
    }
}
