import SwiftUI

struct NeedsAttentionCard: View {
    let category: Category
    let spent: Double
    let limit: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var shakeCount: CGFloat = 0

    private var percent: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }

    private var isOverBudget: Bool {
        percent >= 1.0
    }

    private var statusColor: Color {
        isOverBudget ? .expenseRed : .orange
    }

    private var statusText: String {
        if isOverBudget {
            return "Over budget"
        }
        return "\(Int(percent * 100))% used"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Pulsing icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .scaleEffect(appeared && !reduceMotion ? 1.08 : 1.0)
                    .animation(
                        reduceMotion ? .none :
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: appeared
                    )

                Image(systemName: category.iconName)
                    .font(.system(size: 15))
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .font(.subheadline.weight(.medium))

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }

            Spacer()

            Text(spent.asCurrency)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(statusColor)
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(statusColor.opacity(0.25), lineWidth: 1)
        )
        .modifier(ShakeEffect(amount: shakeCount))
        .onAppear {
            appeared = true
            if isOverBudget && !reduceMotion {
                withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                    shakeCount = 2
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.title), \(statusText), spent \(spent.asCurrency) of \(limit.asCurrency)")
    }
}
