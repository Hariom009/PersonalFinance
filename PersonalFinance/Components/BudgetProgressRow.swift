import SwiftUI

struct BudgetProgressRow: View {
    let category: Category
    let spent: Double
    let limit: Double

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    private var statusColor: Color {
        if progress >= 1.0 { return .expenseRed }
        if progress >= 0.8 { return .orange }
        return .appPrimary
    }

    private var isOverBudget: Bool {
        spent > limit
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: category.iconName)
                        .font(.system(size: 14))
                        .foregroundStyle(category.color)
                }

                Text(category.title)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("\(spent.asCurrency) / \(limit.asCurrency)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 8)

            if isOverBudget {
                HStack {
                    Spacer()
                    Text("Over by \((spent - limit).asCurrency)")
                        .font(.caption2)
                        .foregroundStyle(.expenseRed)
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.title) budget: \(spent.asCurrency) of \(limit.asCurrency), \(Int(min(progress, 1.0) * 100)) percent")
    }
}
