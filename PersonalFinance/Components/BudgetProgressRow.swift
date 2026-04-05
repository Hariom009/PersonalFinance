import SwiftUI

struct BudgetProgressRow: View {
    let category: Category
    let spent: Double
    let limit: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0
    @State private var shakeAmount: CGFloat = 0

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    private var statusColor: Color {
        if progress >= 1.0 { return .expenseRed }
        if progress >= 0.8 { return .orange }
        return .incomeGreen
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
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(statusColor)
                        .frame(width: geo.size.width * min(animatedProgress, 1.0), height: 8)
                }
            }
            .frame(height: 8)

            if isOverBudget {
                HStack {
                    Spacer()
                    Text("Over by \((spent - limit).asCurrency)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.expenseRed)
                        .modifier(ShakeEffect(amount: shakeAmount))
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            if reduceMotion {
                animatedProgress = min(progress, 1.0)
            } else {
                withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                    animatedProgress = min(progress, 1.0)
                }
                if isOverBudget {
                    withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                        shakeAmount = 1
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(category.title) budget: \(spent.asCurrency) of \(limit.asCurrency), \(Int(min(progress, 1.0) * 100)) percent")
    }
}
