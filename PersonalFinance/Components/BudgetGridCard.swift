import SwiftUI

struct BudgetGridCard: View {
    let category: Category
    let spent: Double
    let limit: Double

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }

    private var percent: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    private var statusColor: Color {
        let pct = percent
        if pct >= 1.0 { return .expenseRed }
        if pct >= 0.8 { return .orange }
        return .incomeGreen
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Image(systemName: category.iconName)
                        .font(.system(size: 13))
                        .foregroundStyle(category.color)
                }

                Text(category.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer()
            }

            BudgetFillCard(
                statusColor: statusColor,
                progress: progress,
                percent: percent,
                spent: spent,
                limit: limit
            )
        }
    }
}
