import Foundation
import SwiftData

struct TransactionFilter {
    var type: TransactionType?
    var category: Category?
    var startDate: Date?
    var endDate: Date?
    var searchText: String?
}

struct TransactionService {
    func add(_ transaction: Transaction, context: ModelContext) {
        context.insert(transaction)
    }

    func delete(_ transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
    }

    func update(
        _ transaction: Transaction,
        amount: Double? = nil,
        type: TransactionType? = nil,
        category: Category? = nil,
        date: Date? = nil,
        note: String? = nil,
        isRecurring: Bool? = nil
    ) {
        if let amount { transaction.amount = amount }
        if let type { transaction.type = type }
        if let category { transaction.category = category }
        if let date { transaction.date = date }
        if let note { transaction.note = note }
        if let isRecurring { transaction.isRecurring = isRecurring }
    }

    func fetch(filter: TransactionFilter? = nil, context: ModelContext) throws -> [Transaction] {
        var descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        if let filter {
            let type = filter.type
            let category = filter.category
            let startDate = filter.startDate
            let endDate = filter.endDate

            descriptor.predicate = #Predicate<Transaction> { transaction in
                (type == nil || transaction.type == type!) &&
                (category == nil || transaction.category == category!) &&
                (startDate == nil || transaction.date >= startDate!) &&
                (endDate == nil || transaction.date <= endDate!)
            }
        }

        var results = try context.fetch(descriptor)

        if let searchText = filter?.searchText, !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter { $0.note.lowercased().contains(query) }
        }

        return results
    }
}
