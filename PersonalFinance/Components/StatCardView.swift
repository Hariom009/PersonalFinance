import SwiftUI

struct StatCardView: View {
    let icon: String
    let amount: Double
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }

            Text(amount.asCurrency)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(amount.asCurrency)")
    }
}

#Preview {
    HStack(spacing: 12) {
        StatCardView(icon: "arrow.up.right", amount: 7570, label: "Income", color: .green)
        StatCardView(icon: "arrow.down.left", amount: 1285, label: "Expenses", color: .red)
        StatCardView(icon: "target", amount: 6850, label: "Saved", color: .blue)
    }
    .padding()
}
