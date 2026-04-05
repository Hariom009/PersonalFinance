import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = DashboardViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 20) {
                        greetingHeader
                        summaryCards
                        weeklySpendingChart
                        categoryBreakdownChart
                        savingsGoalsSection
                        recentTransactionsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear { viewModel.loadData(context: context) }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.greeting)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(viewModel.balance.asCurrency)
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("This month's balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCardView(
                icon: "arrow.up.right",
                amount: viewModel.monthlyIncome,
                label: "Income",
                color: .incomeGreen
            )
            StatCardView(
                icon: "arrow.down.left",
                amount: viewModel.monthlyExpenses,
                label: "Expenses",
                color: .expenseRed
            )
            StatCardView(
                icon: "target",
                amount: viewModel.totalSaved,
                label: "Saved",
                color: .appPrimary
            )
        }
    }

    // MARK: - Weekly Spending Chart

    private var weeklySpendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "This Week", subtitle: "Daily spending")

            Chart(viewModel.weeklySpending) { day in
                BarMark(
                    x: .value("Day", day.day),
                    y: .value("Amount", day.amount)
                )
                .foregroundStyle(day.isToday ? Color.appPrimary : Color.appPrimary.opacity(0.4))
                .cornerRadius(6)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(.secondary.opacity(0.3))
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Spending by Category")

            if viewModel.categoryBreakdown.isEmpty {
                Text("No expenses this month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart(viewModel.categoryBreakdown) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                }
                .frame(height: 180)

                categoryLegend
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var categoryLegend: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.categoryBreakdown) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.category.color)
                        .frame(width: 10, height: 10)

                    Text(item.category.title)
                        .font(.caption)

                    Spacer()

                    Text(item.amount.asCurrency)
                        .font(.caption.weight(.medium))

                    Text("\(Int(item.percentage * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
    }

    // MARK: - Savings Goals

    private var savingsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Savings Goals")

            if viewModel.goals.isEmpty {
                Text("No savings goals yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.goals) { goal in
                            GoalCardView(goal: goal)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Transactions",
                buttonTitle: "See All"
            ) {
                selectedTab = 1
            }

            if viewModel.recentTransactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)

                        if index < viewModel.recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    @Previewable @State var tab = 0
    DashboardView(selectedTab: $tab)
        .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
}
