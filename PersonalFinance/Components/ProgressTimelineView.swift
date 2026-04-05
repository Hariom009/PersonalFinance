import SwiftUI

struct ProgressTimelineView: View {
    let currentDay: Int
    let targetDays: Int
    let personalBest: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    private var progressFraction: Double {
        guard targetDays > 0 else { return 0 }
        return min(Double(currentDay) / Double(targetDays), 1.0)
    }

    private var personalBestFraction: Double {
        guard targetDays > 0 else { return 0 }
        return min(Double(personalBest) / Double(targetDays), 1.0)
    }

    private let trackHeight: CGFloat = 10

    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack {
                Text("Day \(currentDay)")
                    .font(.system(.headline, design: .rounded).weight(.bold))

                Spacer()

                Text("Target: \(targetDays) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Timeline track
            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: trackHeight)

                    // Filled progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(trackHeight, width * animatedProgress), height: trackHeight)

                    // Personal best flag
                    if personalBest > 0 && personalBestFraction < 1.0 {
                        VStack(spacing: 2) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.orange)

                            Rectangle()
                                .fill(Color.orange.opacity(0.4))
                                .frame(width: 1, height: 8)
                        }
                        .offset(x: width * personalBestFraction - 6, y: -16)
                    }

                    // Current position indicator
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 1)
                        .overlay(
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                        )
                        .offset(x: max(0, width * animatedProgress - 8))
                }
                .frame(height: trackHeight)
            }
            .frame(height: trackHeight + 4)
            .padding(.top, 18)

            // Labels
            HStack {
                Text("Start")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                if personalBest > 0 {
                    Text("Best: \(personalBest)d")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.orange)
                }

                Spacer()

                Text("Day \(targetDays)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .onAppear {
            if reduceMotion {
                animatedProgress = progressFraction
            } else {
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    animatedProgress = progressFraction
                }
            }
        }
        .onChange(of: currentDay) {
            let target = progressFraction
            if reduceMotion {
                animatedProgress = target
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedProgress = target
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: day \(currentDay) of \(targetDays). Personal best: \(personalBest) days.")
    }
}
