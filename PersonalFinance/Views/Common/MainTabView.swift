import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var goalSegment: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab, goalSegment: $goalSegment)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            GoalsListView(selectedSegment: $goalSegment)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .tint(.appPrimary)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Transaction.self, SavingsGoal.self, GoalContribution.self, NoSpendChallenge.self, Budget.self], inMemory: true)
}
