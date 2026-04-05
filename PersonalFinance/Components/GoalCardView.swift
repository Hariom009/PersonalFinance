import SwiftUI

struct GoalCardView: View {
    let goal: SavingsGoal

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.decorativeIconBg)
                    .frame(width: 40, height: 40)

                Image(systemName: goal.iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }

            Text(goal.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.incomeGreen.opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.incomeGreen)
                        .frame(width: geo.size.width * animatedProgress, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(goal.currentAmount.asCurrency) of \(goal.targetAmount.asCurrency)")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(width: 160)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .onAppear {
            if reduceMotion {
                animatedProgress = goal.progress
            } else {
                withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                    animatedProgress = goal.progress
                }
            }
        }
    }
}
