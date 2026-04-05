import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("userName") private var userName = ""
    @State private var viewModel = DashboardViewModel()
    @State private var showAddTransaction = false
    @State private var showAddGoal = false
    @State private var selectedDay: String?
    @Binding var selectedTab: Int

    // Animation states
    @State private var hasAppeared = false
    @State private var budgetBarProgress: Double = 0
    @State private var chartProgress: Double = 0
    @State private var donutProgress: Double = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    if viewModel.isLoading {
                        ProgressView("Loading your finances...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                    } else if let errorMessage = viewModel.errorMessage {
                        errorBanner(errorMessage)
                    } else {
                        VStack(spacing: 16) {
                            inlineNavBar
                            greetingHeader
                                .staggered(index: 0, appeared: hasAppeared, reduceMotion: reduceMotion)
                            summaryCards
                                .staggered(index: 1, appeared: hasAppeared, reduceMotion: reduceMotion)
                            budgetHealthBar
                                .staggered(index: 2, appeared: hasAppeared, reduceMotion: reduceMotion)
                            weeklySpendingChart
                                .staggered(index: 3, appeared: hasAppeared, reduceMotion: reduceMotion)
                            categoryBreakdownChart
                                .staggered(index: 4, appeared: hasAppeared, reduceMotion: reduceMotion)
                            savingsGoalsSection
                                .staggered(index: 5, appeared: hasAppeared, reduceMotion: reduceMotion)
                            recentTransactionsSection
                                .staggered(index: 6, appeared: hasAppeared, reduceMotion: reduceMotion)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                }
                .refreshable {
                    viewModel.loadData(context: context)
                    resetAnimations()
                }
                .background {
                    ZStack(alignment: .top) {
                        Color.appBackground
                            .ignoresSafeArea()

                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.18),
                                Color.appPrimary.opacity(0.06),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top)
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    viewModel.loadData(context: context)
                    triggerAnimations()
                }

                fab
            }
            .sheet(isPresented: $showAddTransaction) {
                viewModel.loadData(context: context)
            } content: {
                NavigationStack {
                    AddTransactionView(
                        viewModel: AddTransactionViewModel(),
                        onSave: { viewModel.loadData(context: context) }
                    )
                }
            }
            .sheet(isPresented: $showAddGoal) {
                viewModel.loadData(context: context)
            } content: {
                NavigationStack {
                    AddGoalView(
                        viewModel: AddGoalViewModel(),
                        onSave: { viewModel.loadData(context: context) }
                    )
                }
            }
        }
    }

    // MARK: - Animation Triggers

    private func triggerAnimations() {
        guard !hasAppeared else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { hasAppeared = true }

            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
                    budgetBarProgress = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    chartProgress = 1.0
                }
                withAnimation(.easeInOut(duration: 0.7).delay(0.35)) {
                    donutProgress = 1.0
                }
            } else {
                budgetBarProgress = 1.0
                chartProgress = 1.0
                donutProgress = 1.0
            }
        }
    }

    private func resetAnimations() {
        hasAppeared = false
        budgetBarProgress = 0
        chartProgress = 0
        donutProgress = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            triggerAnimations()
        }
    }

    // MARK: - FAB

    private var fab: some View {
        Button {
            showAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(hasAppeared ? 1 : 0)
        .animation(
            reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6).delay(0.45),
            value: hasAppeared
        )
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                viewModel.loadData(context: context)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    // MARK: - Inline Nav Bar

    private var inlineNavBar: some View {
        HStack {
//            Text("Home")
//                .font(.headline)

            Spacer()

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting(for: userName))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                AnimatingCurrencyView(
                    value: viewModel.balance,
                    font: .system(size: 28, weight: .bold, design: .rounded),
                    reduceMotion: reduceMotion
                )

                Text("this month")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
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
            .scaleEntrance(appeared: hasAppeared, delay: 0.1, reduceMotion: reduceMotion)

            StatCardView(
                icon: "arrow.down.left",
                amount: viewModel.monthlyExpenses,
                label: "Expenses",
                color: .expenseRed
            )
            .scaleEntrance(appeared: hasAppeared, delay: 0.16, reduceMotion: reduceMotion)

            StatCardView(
                icon: "wallet.pass",
                amount: viewModel.leftToSpend,
                label: "Left to Spend",
                color: .appPrimary
            )
            .scaleEntrance(appeared: hasAppeared, delay: 0.22, reduceMotion: reduceMotion)
        }
    }

    // MARK: - Budget Health Bar

    @ViewBuilder
    private var budgetHealthBar: some View {
        if viewModel.hasBudgets {
            let percent = viewModel.budgetUsagePercent
            let statusColor: Color = {
                if percent >= 1.0 { return .expenseRed }
                if percent >= 0.8 { return .orange }
                return .appPrimary
            }()

            VStack(spacing: 8) {
                HStack {
                    Text("Budget")
                        .font(.system(.subheadline, design: .serif).weight(.medium))

                    Spacer()

                    Text("\(Int(min(percent, 1.0) * 100))% used")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(statusColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(statusColor.opacity(0.15))
                            .frame(height: 8)

                        Capsule()
                            .fill(statusColor)
                            .frame(
                                width: geo.size.width * min(percent, 1.0) * budgetBarProgress,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(viewModel.totalBudgetSpent.asCurrency)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.totalBudgetLimit.asCurrency)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Budget: \(Int(min(percent, 1.0) * 100)) percent used, \(viewModel.totalBudgetSpent.asCurrency) of \(viewModel.totalBudgetLimit.asCurrency)")
        }
    }

    // MARK: - Weekly Spending Chart

    private var weeklySpendingChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Last 7 Days", subtitle: "Daily spending")

            Chart(viewModel.weeklySpending) { day in
                BarMark(
                    x: .value("Day", day.day),
                    y: .value("Amount", day.amount * chartProgress)
                )
                .foregroundStyle(day.isToday ? Color.appPrimary : Color.appPrimary.opacity(0.4))
                .cornerRadius(6)
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let x = value.location.x - geo[proxy.plotFrame!].origin.x
                                    if let day: String = proxy.value(atX: x) {
                                        selectedDay = selectedDay == day ? nil : day
                                    }
                                }
                        )
                }
            }
            .chartOverlay { proxy in
                if let selectedDay,
                   let dayData = viewModel.weeklySpending.first(where: { $0.day == selectedDay }) {
                    GeometryReader { geo in
                        if let anchor = proxy.position(forX: selectedDay) {
                            let xPos = anchor + geo[proxy.plotFrame!].origin.x

                            VStack(spacing: 2) {
                                Text(dayData.amount.asCurrency)
                                    .font(.system(.caption, design: .rounded).weight(.semibold))
                                Text(dayData.day)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                            .position(x: xPos, y: 0)
                        }
                    }
                }
            }
            .frame(height: 150)
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
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Spending by Category")

            if viewModel.categoryBreakdown.isEmpty {
                emptyStateView(
                    icon: "chart.pie",
                    message: "No expenses this month",
                    subtitle: "Start tracking to see where your money goes"
                )
            } else {
                ZStack {
                    Chart(viewModel.categoryBreakdown) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount * donutProgress),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.category.color)
                        .cornerRadius(4)
                    }
                    .frame(height: 140)

                    VStack(spacing: 2) {
                        Text(viewModel.totalMonthlyExpenses.asCurrency)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .opacity(donutProgress > 0.5 ? 1 : 0)
                            .animation(.easeIn(duration: 0.3), value: donutProgress > 0.5)
                        Text("total")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .opacity(donutProgress > 0.5 ? 1 : 0)
                            .animation(.easeIn(duration: 0.3), value: donutProgress > 0.5)
                    }
                }

                categoryLegend
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var categoryLegend: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(viewModel.categoryBreakdown) { item in
                Button {
                    selectedTab = 1
                } label: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 8, height: 8)

                        Text(item.category.title)
                            .font(.caption2)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Spacer()

                        Text("\(Int(item.percentage * 100))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Savings Goals

    private var savingsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Savings Goals",
                buttonTitle: "See All"
            ) {
                selectedTab = 2
            }

            if viewModel.goals.isEmpty {
                VStack(spacing: 12) {
                    emptyStateView(
                        icon: "target",
                        message: "No savings goals yet",
                        subtitle: "Set a goal to start tracking your progress"
                    )

                    Button {
                        showAddGoal = true
                    } label: {
                        Label("Create a Goal", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.goals) { goal in
                            NavigationLink {
                                GoalDetailView(goal: goal)
                            } label: {
                                GoalCardView(goal: goal)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showAddGoal = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundStyle(.appPrimary)
                                Text("New Goal")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 160, height: 120)
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundStyle(.secondary.opacity(0.3))
                            )
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
                VStack(spacing: 12) {
                    emptyStateView(
                        icon: "list.bullet.rectangle",
                        message: "No transactions yet",
                        subtitle: "Add your first transaction to get started"
                    )

                    Button {
                        showAddTransaction = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.appPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)

                        if index < viewModel.recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 46)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - Empty State Helper

    private func emptyStateView(icon: String, message: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.secondary.opacity(0.5))

            Text(message)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}

#Preview {
    @Previewable @State var tab = 0
    DashboardView(selectedTab: $tab)
        .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
}
