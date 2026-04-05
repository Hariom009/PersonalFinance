import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var color: Color = .incomeGreen
    var showMilestones: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    private let milestones: [Double] = [0.25, 0.50, 0.75]

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // Milestone markers
            if showMilestones {
                ForEach(milestones, id: \.self) { milestone in
                    milestoneMarker(at: milestone)
                }
            }

            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(.title, design: .rounded).bold())
                    .contentTransition(.numericText())

                Text("saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 180, height: 180)
        .onAppear {
            if reduceMotion {
                animatedProgress = progress
            } else {
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            if reduceMotion {
                animatedProgress = newValue
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animatedProgress = newValue
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress: \(Int(progress * 100)) percent saved")
    }

    private func milestoneMarker(at milestone: Double) -> some View {
        let angle = Angle.degrees(-90 + milestone * 360)
        let radius: CGFloat = 90 - lineWidth / 2 // center of the track
        let reached = animatedProgress >= milestone

        return Circle()
            .fill(reached ? color : color.opacity(0.3))
            .frame(width: 6, height: 6)
            .offset(
                x: radius * cos(CGFloat(angle.radians)),
                y: radius * sin(CGFloat(angle.radians))
            )
    }
}

#Preview {
    VStack(spacing: 30) {
        CircularProgressView(progress: 0.65)
        CircularProgressView(progress: 0.30, showMilestones: false)
    }
}
