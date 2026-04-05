import SwiftUI
import SwiftData
import AVFoundation

private final class SwipeSoundPlayer: @unchecked Sendable {
    private var player: AVAudioPlayer?
    private let queue = DispatchQueue(label: "swipe-sound", qos: .userInteractive)

    init() {
        guard let url = Bundle.main.url(forResource: "swipe_sound", withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
    }

    func play() {
        queue.async { [weak self] in
            self?.player?.currentTime = 0
            self?.player?.play()
        }
    }
}

struct GoalCarouselView: View {
    let goals: [SavingsGoal]
    let onAddGoal: () -> Void
    let onSelectGoal: (SavingsGoal) -> Void
    var onQuickAddFunds: ((SavingsGoal) -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var appeared: Bool = false
    private let soundPlayer = SwipeSoundPlayer()

    private let cardWidth: CGFloat = 190
    private let cardHeight: CGFloat = 276
    private let exposedWidth: CGFloat = 62

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                    if shouldRender(index: index) {
                        GoalCarouselCardView(
                            goal: goal,
                            depth: depthLevel(for: index)
                        )
                        .offset(x: xOffset(for: index))
                        .scaleEffect(scale(for: index))
                        .zIndex(zIndex(for: index))
                        .opacity(cardOpacity(for: index))
                        .onTapGesture {
                            if index == currentIndex {
                                onSelectGoal(goal)
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentIndex = index
                                }
                            }
                        }
                        .contextMenu {
                            Button {
                                onSelectGoal(goal)
                            } label: {
                                Label("View Details", systemImage: "eye")
                            }

                            if !goal.isCompleted, let onQuickAddFunds {
                                Button {
                                    onQuickAddFunds(goal)
                                } label: {
                                    Label("Add Funds", systemImage: "plus.circle")
                                }
                            }
                        }
                        .scaleEffect(appeared ? 1.0 : 0.88)
                        .opacity(appeared ? 1.0 : 0)
                        .animation(
                            reduceMotion
                                ? .none
                                : .spring(response: 0.4, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.05),
                            value: appeared
                        )
                    }
                }
            }
            .frame(height: cardHeight + 10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        // Only respond to primarily horizontal drags
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        let velocity = value.predictedEndTranslation.width - value.translation.width

                        var newIndex = currentIndex
                        if value.translation.width < -threshold || velocity < -200 {
                            newIndex = min(currentIndex + 1, goals.count - 1)
                        } else if value.translation.width > threshold || velocity > 200 {
                            newIndex = max(currentIndex - 1, 0)
                        }

                        let animation: Animation = reduceMotion
                            ? .easeOut(duration: 0.15)
                            : .spring(response: 0.4, dampingFraction: 0.8)

                        withAnimation(animation) {
                            currentIndex = newIndex
                            dragOffset = 0
                        }
                    }
            )

            CarouselPageIndicator(count: goals.count, current: currentIndex)
        }
        .onAppear {
            guard !appeared else { return }
            if reduceMotion {
                appeared = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appeared = true
                }
            }
        }
        .onChange(of: currentIndex) {
            soundPlayer.play()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Savings goals carousel, \(goals.count) goals")
        .accessibilityHint("Swipe left or right to browse goals")
    }

    // MARK: - Layout Calculations

    private func shouldRender(index: Int) -> Bool {
        let relative = index - currentIndex
        return relative >= -1 && relative <= 3
    }

    private func xOffset(for index: Int) -> CGFloat {
        let relative = CGFloat(index - currentIndex)
        let base = relative * exposedWidth

        // Apply drag offset with parallax — front card moves more, back cards less
        let dragFactor: CGFloat = index >= currentIndex ? 1.0 : 0.3
        return base + dragOffset * dragFactor
    }

    private func zIndex(for index: Int) -> Double {
        let distance = abs(index - currentIndex)
        return Double(goals.count - distance)
    }

    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - currentIndex)
        if distance == 0 { return 1.0 }
        return max(1.0 - CGFloat(distance) * 0.03, 0.9)
    }

    private func depthLevel(for index: Int) -> CardDepth {
        let distance = abs(index - currentIndex)
        switch distance {
        case 0: return .front
        case 1: return .middle
        default: return .back
        }
    }

    private func cardOpacity(for index: Int) -> Double {
        let relative = index - currentIndex
        if relative < -1 { return 0 }
        if relative > 3 { return 0 }
        return 1.0
    }
}

#Preview {
    VStack {
        GoalCarouselView(
            goals: [
                SavingsGoal(
                    name: "Dream Home",
                    targetAmount: 500000,
                    currentAmount: 125000,
                    deadline: Calendar.current.date(byAdding: .month, value: 18, to: .now)!,
                    iconName: "house.fill"
                ),
                SavingsGoal(
                    name: "Vacation",
                    targetAmount: 50000,
                    currentAmount: 32000,
                    deadline: Calendar.current.date(byAdding: .month, value: 6, to: .now)!,
                    iconName: "airplane"
                ),
                SavingsGoal(
                    name: "New Car",
                    targetAmount: 800000,
                    currentAmount: 200000,
                    deadline: Calendar.current.date(byAdding: .year, value: 2, to: .now)!,
                    iconName: "car.fill"
                ),
                SavingsGoal(
                    name: "Emergency Fund",
                    targetAmount: 100000,
                    currentAmount: 95000,
                    deadline: Calendar.current.date(byAdding: .month, value: 3, to: .now)!,
                    iconName: "shield.fill"
                ),
            ],
            onAddGoal: {},
            onSelectGoal: { _ in }
        )
    }
    .padding()
    .modelContainer(for: SavingsGoal.self, inMemory: true)
}
