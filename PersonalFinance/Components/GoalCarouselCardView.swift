import SwiftUI
import SwiftData

enum CardDepth {
    case front, middle, back

    var shadowColor: Color {
        switch self {
        case .front: .black.opacity(0.16)
        case .middle: .black.opacity(0.08)
        case .back: .black.opacity(0.02)
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .front: 16
        case .middle: 8
        case .back: 2
        }
    }

    var shadowOffset: CGSize {
        switch self {
        case .front: CGSize(width: 4, height: 4)
        case .middle: CGSize(width: 4, height: 4)
        case .back: CGSize(width: 1, height: 1)
        }
    }
}

struct GoalCarouselCardView: View {
    let goal: SavingsGoal
    let depth: CardDepth

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            // MARK: - Top: Icon + Name + Status
            HStack(spacing: 10) {
                Text(goal.name)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 28, height: 28)

                    Image(systemName: goal.iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }
            }

            Spacer()

            // MARK: - Middle: Deadline + Progress Ring
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(deadlineLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(daysRemainingLabel)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image("Chip")
                    .resizable()
                    .scaledToFit()
                    .frame(width:28,height: 28)
            }

            Spacer()

            // MARK: - Bottom: Amount + Target
            VStack(alignment: .leading) {
                HStack{
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.currentAmount.asCurrency)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("of \(goal.targetAmount.asCurrency) target")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.primary.opacity(0.6))
                    }
                    
                    Spacer()
                    // Mini progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.incomeGreen.opacity(0.15), lineWidth: 3)

                        Circle()
                            .trim(from: 0, to: animatedProgress)
                            .stroke(
                                goal.isCompleted ? Color.incomeGreen : Color.appPrimary,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(goal.progress * 100))%")
                            .font(.system(size: 6, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 24, height: 24)
                }
            }
        }
        .padding(24)
        .frame(width: 190, height: 276)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardBackground)

                // Decorative pattern overlay
                DecorativePattern()
                    .stroke(Color.appPrimary.opacity(0.05), lineWidth: 1.5)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: depth.shadowColor,
            radius: depth.shadowRadius,
            x: depth.shadowOffset.width,
            y: depth.shadowOffset.height
        )
        .onAppear {
            if reduceMotion {
                animatedProgress = goal.progress
            } else {
                withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                    animatedProgress = goal.progress
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(goal.name), \(goal.currentAmount.asCurrency) of \(goal.targetAmount.asCurrency), \(Int(goal.progress * 100)) percent complete")
    }

    private var deadlineLabel: String {
        goal.deadline.formatted(.dateTime.month(.abbreviated).year())
    }

    private var daysRemainingLabel: String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: goal.deadline).day ?? 0
        if days < 0 { return "Overdue" }
        if days == 0 { return "Due today" }
        return "\(days) days left"
    }

}

// MARK: - Decorative Pattern

private struct DecorativePattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let cx = rect.width * 0.7
        let cy = rect.height * 0.45

        // Large star-like shape
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let radius: CGFloat = 130
            let x = cx + cos(angle) * radius
            let y = cy + sin(angle) * radius
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Inner smaller pattern
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 + .pi / 6
            let radius: CGFloat = 85
            let x = cx + cos(angle) * radius
            let y = cy + sin(angle) * radius
            path.move(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

#Preview {
    HStack(spacing: -128) {
        GoalCarouselCardView(
            goal: SavingsGoal(
                name: "Dream Home",
                targetAmount: 500000,
                currentAmount: 125000,
                deadline: Calendar.current.date(byAdding: .month, value: 18, to: .now)!,
                iconName: "house.fill"
            ),
            depth: .front
        )
        .zIndex(3)

        GoalCarouselCardView(
            goal: SavingsGoal(
                name: "Vacation",
                targetAmount: 50000,
                currentAmount: 32000,
                deadline: Calendar.current.date(byAdding: .month, value: 6, to: .now)!,
                iconName: "airplane"
            ),
            depth: .middle
        )
        .zIndex(2)

        GoalCarouselCardView(
            goal: SavingsGoal(
                name: "New Car",
                targetAmount: 800000,
                currentAmount: 200000,
                deadline: Calendar.current.date(byAdding: .year, value: 2, to: .now)!,
                iconName: "car.fill"
            ),
            depth: .back
        )
        .zIndex(1)
    }
    .padding()
    .modelContainer(for: SavingsGoal.self, inMemory: true)
}
