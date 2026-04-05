import SwiftUI
import SwiftData
import Charts

private struct WeeklyEntry: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
    let series: String
}

private struct TrendEntry: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
    let type: String
}

struct InsightsView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                } else {
                    VStack(spacing: 20) {
                        topCategoryCard
                        weeklyComparisonChart
                        monthlyTrendChart
                        categoryRankingChart
                        quickStatsGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.loadData(context: context) }
        }
    }

    // MARK: - Top Spending Category

    @ViewBuilder
    private var topCategoryCard: some View {
        if let top = viewModel.topCategory {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(top.category.color.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Image(systemName: top.category.iconName)
                            .font(.title3)
                            .foregroundStyle(top.category.color)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Top Spending")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(top.category.title)
                            .font(.title3.bold())

                        Text(top.amount.asCurrency)
                            .font(.headline)
                            .foregroundStyle(top.category.color)
                    }
                }

                if top.lastMonthAmount > 0 {
                    let isUp = top.percentChange >= 0
                    HStack(spacing: 4) {
                        Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        Text("\(abs(top.percentChange), specifier: "%.0f")% vs last month")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isUp ? Color.expenseRed : Color.incomeGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background((isUp ? Color.expenseRed : Color.incomeGreen).opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Weekly Comparison

    private var weeklyComparisonChart: some View {
        let comp = viewModel.weeklyComparison
        var entries: [WeeklyEntry] = []
        for day in comp.thisWeek {
            entries.append(WeeklyEntry(day: day.day, amount: day.amount, series: "This Week"))
        }
        for day in comp.lastWeek {
            entries.append(WeeklyEntry(day: day.day, amount: day.amount, series: "Last Week"))
        }

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Weekly Comparison", subtitle: "This week vs last week")

            Chart(entries) { entry in
                BarMark(
                    x: .value("Day", entry.day),
                    y: .value("Amount", entry.amount)
                )
                .foregroundStyle(by: .value("Week", entry.series))
                .position(by: .value("Week", entry.series))
                .cornerRadius(4)
            }
            .chartForegroundStyleScale([
                "This Week": Color.appPrimary,
                "Last Week": Color.appPrimary.opacity(0.3)
            ])
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
                    AxisValueLabel().font(.caption)
                }
            }
            .chartLegend(position: .bottom, alignment: .leading)

            let verb = comp.percentChange >= 0 ? "more" : "less"
            Text("You spent \(abs(comp.percentChange), specifier: "%.0f")% \(verb) than last week")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Monthly Trend

    private var monthlyTrendChart: some View {
        let trend = viewModel.monthlyTrend
        var entries: [TrendEntry] = []
        for data in trend {
            entries.append(TrendEntry(month: data.month, amount: data.income, type: "Income"))
            entries.append(TrendEntry(month: data.month, amount: data.expenses, type: "Expenses"))
        }

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Monthly Trend", subtitle: "Last 6 months")

            Chart(entries) { entry in
                LineMark(
                    x: .value("Month", entry.month),
                    y: .value("Amount", entry.amount)
                )
                .foregroundStyle(by: .value("Type", entry.type))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                AreaMark(
                    x: .value("Month", entry.month),
                    y: .value("Amount", entry.amount)
                )
                .foregroundStyle(by: .value("Type", entry.type))
                .opacity(0.1)
                .interpolationMethod(.catmullRom)
            }
            .chartForegroundStyleScale([
                "Income": Color.incomeGreen,
                "Expenses": Color.expenseRed
            ])
            .frame(height: 220)
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
                    AxisValueLabel().font(.caption)
                }
            }
            .chartLegend(position: .bottom, alignment: .leading)
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Category Ranking

    private var categoryRankingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Spending by Category", subtitle: "This month")

            if viewModel.categoryRanking.isEmpty {
                Text("No expenses this month")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart(viewModel.categoryRanking) { item in
                    BarMark(
                        x: .value("Amount", item.amount),
                        y: .value("Category", item.category.title)
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                    .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                        Text(item.amount.asCurrency)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel().font(.caption)
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
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
                .frame(height: CGFloat(viewModel.categoryRanking.count) * 44)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Quick Stats

    private var quickStatsGrid: some View {
        let stats = viewModel.quickStats
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Stats")

            LazyVGrid(columns: columns, spacing: 12) {
                quickStatCard(
                    icon: "calendar",
                    value: stats.averageDailySpend.asCurrency,
                    label: "Avg. Daily Spend",
                    color: .appPrimary
                )

                quickStatCard(
                    icon: stats.mostFrequentCategory?.iconName ?? "questionmark.circle",
                    value: stats.mostFrequentCategory?.title ?? "N/A",
                    label: "Most Frequent",
                    color: stats.mostFrequentCategory?.color ?? .gray
                )

                quickStatCard(
                    icon: "flame.fill",
                    value: stats.biggestExpense?.amount.asCurrency ?? "$0",
                    label: stats.biggestExpense?.note.isEmpty == false ? stats.biggestExpense!.note : "Biggest Expense",
                    color: .expenseRed
                )

                quickStatCard(
                    icon: "clock.arrow.circlepath",
                    value: "\(stats.daysSinceLastIncome)d",
                    label: "Since Last Income",
                    color: .appSecondary
                )
            }
        }
    }

    private func quickStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
}
