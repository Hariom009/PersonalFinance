import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: transaction.category.iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(transaction.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.title)
                    .font(.caption.weight(.medium))

                Text(transaction.note.isEmpty ? "No note" : transaction.note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountText)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(transaction.type == .income ? .incomeGreen : .expenseRed)

                Text(transaction.date.formattedRelative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
