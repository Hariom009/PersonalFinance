import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var color: Color = .appPrimary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

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
}

#Preview {
    CircularProgressView(progress: 0.65)
}
