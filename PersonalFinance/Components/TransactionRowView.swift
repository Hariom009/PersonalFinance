import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.category.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(transaction.category.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.category.title)
                    .font(.subheadline.weight(.medium))

                Text(transaction.note.isEmpty ? "No note" : transaction.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(amountText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.type == .income ? .incomeGreen : .expenseRed)

                Text(transaction.date.formattedRelative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(transaction.type == .income ? "Income" : "Expense") \(transaction.amount.asCurrency) for \(transaction.category.title), \(transaction.date.formattedRelative)")
    }

    private var amountText: String {
        switch transaction.type {
        case .income:
            "+\(transaction.amount.asCurrency)"
        case .expense:
            "-\(transaction.amount.asCurrencyAbs)"
        }
    }
}
