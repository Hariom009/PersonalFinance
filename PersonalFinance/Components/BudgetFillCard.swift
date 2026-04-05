import SwiftUI

// MARK: - Wave Shape

private struct WaveShape: Shape {
    var progress: Double
    var waveHeight: Double
    var phase: Double

    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get { AnimatablePair(progress, AnimatablePair(waveHeight, phase)) }
        set {
            progress = newValue.first
            waveHeight = newValue.second.first
            phase = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let waterY = rect.height * (1.0 - progress)
        var path = Path()

        path.move(to: CGPoint(x: 0, y: waterY))

        let wavelength = rect.width * 0.8
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + phase) * 2 * .pi)
            let y = waterY + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Budget Fill Card

struct BudgetFillCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let statusColor: Color
    let progress: Double
    let percent: Double
    let spent: Double
    let limit: Double

    @State private var wavePhase: Double = 0

    private var lightFill: Double { colorScheme == .dark ? 0.22 : 0.14 }
    private var heavyFill: Double { colorScheme == .dark ? 0.32 : 0.22 }

    private var frontWaveHeight: Double {
        progress > 0.01 ? 4.0 : 0
    }

    private var backWaveHeight: Double {
        progress > 0.01 ? 3.0 : 0
    }

    // Blended gradient: green base → orange mid → red top, weighted by progress
    // As progress rises, orange and red become more visible at the surface.
    private var fluidGradient: LinearGradient {
        let orangeAmount = max(0, (progress - 0.4) / 0.4)   // fades in 40-80%
        let redAmount    = max(0, (progress - 0.7) / 0.3)    // fades in 70-100%

        return LinearGradient(
            stops: [
                .init(color: Color.green.opacity(heavyFill), location: 0),
                .init(color: Color.green.opacity(lightFill), location: 0.45),
                .init(color: Color.orange.opacity(lightFill * orangeAmount), location: 0.7),
                .init(color: Color.red.opacity(heavyFill * redAmount), location: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private var backFluidGradient: LinearGradient {
        let orangeAmount = max(0, (progress - 0.4) / 0.4)
        let redAmount    = max(0, (progress - 0.7) / 0.3)

        return LinearGradient(
            stops: [
                .init(color: Color.green.opacity(heavyFill), location: 0),
                .init(color: Color.green.opacity(heavyFill), location: 0.5),
                .init(color: Color.orange.opacity(heavyFill * orangeAmount), location: 0.75),
                .init(color: Color.red.opacity(heavyFill * redAmount), location: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Budget")
                    .font(.system(.subheadline, design: .serif).weight(.medium))

                Spacer()

                Text("\(Int(min(percent, 1.0) * 100))% used")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(statusColor)
            }

            HStack {
                Text(spent.asCurrency)
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(limit.asCurrency)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cardBackground)

                // Back wave (slower, slightly offset)
                WaveShape(
                    progress: progress,
                    waveHeight: backWaveHeight,
                    phase: wavePhase * 0.7 + 0.5
                )
                .fill(backFluidGradient)

                // Front wave
                WaveShape(
                    progress: progress,
                    waveHeight: frontWaveHeight,
                    phase: wavePhase
                )
                .fill(fluidGradient)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .animation(.easeInOut(duration: 0.8), value: progress)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .linear(duration: 3.0)
                .repeatForever(autoreverses: false)
            ) {
                wavePhase = 1.0
            }
        }
    }

}
