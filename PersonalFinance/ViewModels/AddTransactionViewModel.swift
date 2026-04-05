import Foundation
import SwiftData

@Observable
final class AddTransactionViewModel {
    var amountText: String = ""
    var type: TransactionType = .expense
    var category: Category? = nil
    var date: Date = .now
    var note: String = ""
    var isRecurring: Bool = false

    private(set) var isEditing: Bool = false
    private var existingTransaction: Transaction? = nil

    private let service = TransactionService()

    // MARK: - Computed

    var amountValue: Double {
        Double(amountText) ?? 0
    }

    var isValid: Bool {
        amountValue > 0 && category != nil
    }

    var validationMessage: String {
        var missing: [String] = []
        if amountValue <= 0 { missing.append("enter an amount") }
        if category == nil { missing.append("select a category") }
        return "Please \(missing.joined(separator: " and ")) to save."
    }

    var availableCategories: [Category] {
        type == .expense ? Category.expenseCategories : Category.incomeCategories
    }

    var saveButtonTitle: String {
        isEditing ? "Update Transaction" : "Add Transaction"
    }

    // MARK: - Init

    init() { }

    init(transaction: Transaction) {
        isEditing = true
        existingTransaction = transaction
        amountText = String(format: "%.2f", transaction.amount)
        type = transaction.type
        category = transaction.category
        date = transaction.date
        note = transaction.note
        isRecurring = transaction.isRecurring
    }

    // MARK: - Methods

    func save(context: ModelContext) {
        guard isValid else { return }

        if isEditing, let existing = existingTransaction {
            service.update(
                existing,
                amount: amountValue,
                type: type,
                category: category,
                date: date,
                note: note,
                isRecurring: isRecurring
            )
        } else {
            let transaction = Transaction(
                amount: amountValue,
                type: type,
                category: category!,
                date: date,
                note: note,
                isRecurring: isRecurring
            )
            service.add(transaction, context: context)
        }
        try? context.save()
    }

    func deleteTransaction(context: ModelContext) {
        guard let existing = existingTransaction else { return }
        service.delete(existing, context: context)
        try? context.save()
    }
}
