import SwiftUI

struct StatCardView: View {
    let icon: String
    let amount: Double
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)

            Text(amount.asCurrency)
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(amount.asCurrency)")
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCardView(icon: "arrow.up.right", amount: 7570, label: "Income", color: .green)
        StatCardView(icon: "arrow.down.left", amount: 1285, label: "Expenses", color: .red)
        StatCardView(icon: "wallet.pass", amount: 6850, label: "Left to Spend", color: .blue)
    }
    .padding()
}
