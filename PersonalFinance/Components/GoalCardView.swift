import SwiftUI

struct GoalCardView: View {
    let goal: SavingsGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: goal.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appPrimary)
            }

            Text(goal.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.appPrimary)
                        .frame(width: geo.size.width * goal.progress, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(goal.currentAmount.asCurrency) of \(goal.targetAmount.asCurrency)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(width: 160)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
