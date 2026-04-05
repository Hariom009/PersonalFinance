import Foundation
import SwiftData

struct BudgetService {
    func add(_ budget: Budget, context: ModelContext) {
        context.insert(budget)
        try? context.save()
    }

    func delete(_ budget: Budget, context: ModelContext) {
        context.delete(budget)
        try? context.save()
    }

    func update(_ budget: Budget, monthlyLimit: Double? = nil) {
        if let monthlyLimit { budget.monthlyLimit = monthlyLimit }
    }

    func fetchBudgets(context: ModelContext) throws -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            sortBy: [SortDescriptor(\.categoryRaw, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    func spentForCategory(_ category: Category, month: Date, transactions: [Transaction]) -> Double {
        let monthStart = month.startOfMonth
        let calendar = Calendar.current
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return 0 }

        return transactions
            .filter { $0.type == .expense && $0.category == category && $0.date >= monthStart && $0.date < monthEnd }
            .reduce(0) { $0 + $1.amount }
    }
}
