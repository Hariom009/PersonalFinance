import SwiftUI

struct CarouselPageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        if count > 1 {
            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<count, id: \.self) { index in
                    Capsule()
                        .fill(Color.appPrimary.opacity(index == current ? 1.0 : 0.16))
                        .frame(width: index == current ? 20 : 10, height: 10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CarouselPageIndicator(count: 5, current: 0)
        CarouselPageIndicator(count: 5, current: 2)
        CarouselPageIndicator(count: 3, current: 1)
        CarouselPageIndicator(count: 1, current: 0)
    }
}
