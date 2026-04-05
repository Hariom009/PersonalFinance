import SwiftUI

// MARK: - Staggered Appearance

struct StaggeredAppearance: ViewModifier {
    let index: Int
    let appeared: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : (reduceMotion ? 0 : 16))
            .animation(
                reduceMotion
                    ? .none
                    : .easeOut(duration: 0.4).delay(Double(index) * 0.06),
                value: appeared
            )
    }
}

extension View {
    func staggered(index: Int, appeared: Bool, reduceMotion: Bool = false) -> some View {
        modifier(StaggeredAppearance(index: index, appeared: appeared, reduceMotion: reduceMotion))
    }
}

// MARK: - Animating Currency Text

struct AnimatingCurrencyView: View {
    let target: Double
    let font: Font
    let design: Font.Design
    let reduceMotion: Bool

    @State private var animationStartTime: Date?
    @State private var animationComplete = false

    private let duration: Double = 0.6

    init(
        value: Double,
        font: Font = .system(size: 28, weight: .bold, design: .rounded),
        design: Font.Design = .rounded,
        reduceMotion: Bool = false
    ) {
        self.target = value
        self.font = font
        self.design = design
        self.reduceMotion = reduceMotion
    }

    var body: some View {
        if reduceMotion || animationComplete {
            Text(target.asCurrency)
                .font(font)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: animationStartTime == nil)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(animationStartTime ?? timeline.date)
                let progress = min(elapsed / duration, 1.0)
                let eased = 1 - pow(1 - progress, 3) // easeOut cubic
                let current = eased * target

                Text(current.asCurrency)
                    .font(font)
                    .onChange(of: progress >= 1.0) { _, done in
                        if done {
                            animationComplete = true
                            animationStartTime = nil
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    animationStartTime = .now
                }
            }
        }
    }
}

// MARK: - Animating Integer Text

struct AnimatingIntView: View {
    let target: Int
    let font: Font
    let reduceMotion: Bool

    @State private var animationStartTime: Date?
    @State private var animationComplete = false

    private let duration: Double = 0.8

    var body: some View {
        if reduceMotion || animationComplete {
            Text("\(target)")
                .font(font)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: animationStartTime == nil)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(animationStartTime ?? timeline.date)
                let progress = min(elapsed / duration, 1.0)
                let eased = 1 - pow(1 - progress, 3)
                let current = Int(eased * Double(target))

                Text("\(current)")
                    .font(font)
                    .onChange(of: progress >= 1.0) { _, done in
                        if done {
                            animationComplete = true
                            animationStartTime = nil
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animationStartTime = .now
                }
            }
        }
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = sin(amount * .pi * 3) * 4 * (1 - amount)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

// MARK: - Scale Entrance

struct ScaleEntrance: ViewModifier {
    let appeared: Bool
    let delay: Double
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1.0 : (reduceMotion ? 1.0 : 0.88))
            .opacity(appeared ? 1 : 0)
            .animation(
                reduceMotion
                    ? .none
                    : .spring(response: 0.4, dampingFraction: 0.75).delay(delay),
                value: appeared
            )
    }
}

extension View {
    func scaleEntrance(appeared: Bool, delay: Double = 0, reduceMotion: Bool = false) -> some View {
        modifier(ScaleEntrance(appeared: appeared, delay: delay, reduceMotion: reduceMotion))
    }
}
