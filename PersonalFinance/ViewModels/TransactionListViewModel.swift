import Foundation
import SwiftData

enum DateFilter: String, CaseIterable, Identifiable {
    case all      = "All Time"
    case today    = "Today"
    case week     = "This Week"
    case month    = "This Month"
    case custom   = "Custom"

    var id: String { rawValue }

    var dateRange: (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date.now
        switch self {
        case .all:
            return nil
        case .today:
            return (now.startOfDay, now)
        case .week:
            return (now.startOfWeek, now)
        case .month:
            return (now.startOfMonth, now)
        case .custom:
            return nil
        }
    }
}

@Observable
final class TransactionListViewModel {
    var transactions: [Transaction] = []
    var isLoading = false
    var searchText: String = ""
    var selectedTypeFilter: TransactionType? = nil
    var selectedCategoryFilter: Category? = nil
    var selectedDateFilter: DateFilter = .all
    var customDateFrom: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    var customDateTo: Date = .now
    var transactionToEdit: Transaction? = nil
    var showingAddSheet: Bool = false

    private let service = TransactionService()

    // MARK: - Computed

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

    var netBalance: Double {
        monthlyIncome - monthlyExpenses
    }

    var lastMonthExpenses: Double {
        let calendar = Calendar.current
        let thisMonthStart = Date.now.startOfMonth
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? thisMonthStart
        return transactions
            .filter { $0.type == .expense && $0.date >= lastMonthStart && $0.date < thisMonthStart }
            .reduce(0) { $0 + $1.amount }
    }

    var spendingTrendPercent: Double {
        guard lastMonthExpenses > 0 else { return 0 }
        return ((monthlyExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
    }

    var activeDateRange: (start: Date, end: Date)? {
        if selectedDateFilter == .custom {
            return (customDateFrom.startOfDay, Calendar.current.date(byAdding: .day, value: 1, to: customDateTo.startOfDay) ?? customDateTo)
        }
        return selectedDateFilter.dateRange
    }

    var filteredTransactions: [Transaction] {
        var result = transactions

        if let range = activeDateRange {
            result = result.filter { $0.date >= range.start && $0.date <= range.end }
        }

        if let type = selectedTypeFilter {
            result = result.filter { $0.type == type }
        }

        if let category = selectedCategoryFilter {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.note.lowercased().contains(query) ||
                $0.category.title.lowercased().contains(query)
            }
        }

        return result
    }

    var groupedTransactions: [(key: String, transactions: [Transaction], sectionIncome: Double, sectionExpenses: Double)] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction -> String in
            if transaction.date.isToday { return "Today" }
            if transaction.date.isYesterday { return "Yesterday" }
            if transaction.date.isThisWeek { return "This Week" }
            return "Earlier"
        }

        let order = ["Today", "Yesterday", "This Week", "Earlier"]
        return order.compactMap { key in
            guard let items = grouped[key], !items.isEmpty else { return nil }
            let income = items.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expenses = items.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            return (key: key, transactions: items, sectionIncome: income, sectionExpenses: expenses)
        }
    }

    // MARK: - Methods

    func fetchTransactions(context: ModelContext) {
        isLoading = true
        do {
            transactions = try service.fetch(context: context)
        } catch {
            transactions = []
        }
        isLoading = false
    }

    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        service.delete(transaction, context: context)
        fetchTransactions(context: context)
    }

    func clearFilters() {
        selectedTypeFilter = nil
        selectedCategoryFilter = nil
        selectedDateFilter = .all
        searchText = ""
    }
}
