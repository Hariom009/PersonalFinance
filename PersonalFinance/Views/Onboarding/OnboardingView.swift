import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            icon: "wallet.bifold.fill",
            title: "Track Your Money",
            subtitle: "Easily log your income and expenses to understand where your money goes every day.",
            color: .appPrimary
        ),
        OnboardingPage(
            icon: "target",
            title: "Set Goals & Challenges",
            subtitle: "Create savings goals, take on no-spend challenges, and set budgets to stay on track.",
            color: .incomeGreen
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Get Smart Insights",
            subtitle: "Visualize your spending patterns with charts and discover where you can save more.",
            color: .appSecondary
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    VStack(spacing: 24) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(page.color.opacity(0.12))
                                .frame(width: 140, height: 140)

                            Image(systemName: page.icon)
                                .font(.system(size: 56))
                                .foregroundStyle(page.color)
                        }

                        Text(page.title)
                            .font(.title.bold())

                        Text(page.subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground)
    }
}

#Preview {
    OnboardingView()
}
