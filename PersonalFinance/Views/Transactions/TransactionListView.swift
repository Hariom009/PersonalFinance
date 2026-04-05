import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = TransactionListViewModel()
    @State private var transactionToDelete: Transaction? = nil
    @State private var hasAppeared = false
    @State private var isFabVisible = true
    @State private var lastScrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if viewModel.transactions.isEmpty {
                    EmptyStateView(
                        iconName: "list.bullet.rectangle",
                        title: "No Transactions Yet",
                        subtitle: "Start tracking your income and expenses to see them here.",
                        actionTitle: "Add Transaction"
                    ) {
                        viewModel.showingAddSheet = true
                    }
                } else {
                    transactionList
                }

                fab
            }

            .searchable(text: $viewModel.searchText, prompt: "Search transactions...")
            .onAppear {
                viewModel.fetchTransactions(context: context)
                guard !hasAppeared else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { hasAppeared = true }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                NavigationStack {
                    AddTransactionView(
                        viewModel: AddTransactionViewModel(),
                        onSave: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                viewModel.fetchTransactions(context: context)
                            }
                        }
                    )
                }
            }
            .sheet(item: $viewModel.transactionToEdit) { transaction in
                NavigationStack {
                    AddTransactionView(
                        viewModel: AddTransactionViewModel(transaction: transaction),
                        onSave: { viewModel.fetchTransactions(context: context) }
                    )
                }
            }
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: Binding(
                    get: { transactionToDelete != nil },
                    set: { if !$0 { transactionToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        withAnimation {
                            viewModel.deleteTransaction(transaction, context: context)
                        }
                        transactionToDelete = nil
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(spacing: 2) {
                    Text("Income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.monthlyIncome.asCurrency)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.incomeGreen)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.monthlyIncome)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 30)

                VStack(spacing: 2) {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.monthlyExpenses.asCurrency)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(.expenseRed)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.monthlyExpenses)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            HStack {
                VStack(spacing: 2) {
                    Text("Net Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.netBalance.asCurrency)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(viewModel.netBalance >= 0 ? .incomeGreen : .expenseRed)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.netBalance)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 30)

                VStack(spacing: 2) {
                    Text("vs Last Month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 3) {
                        Image(systemName: trendIconName)
                            .font(.system(size: 10, weight: .bold))
                        Text(String(format: "%.0f%%", abs(viewModel.spendingTrendPercent)))
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    }
                    .foregroundStyle(trendColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .scaleEntrance(appeared: hasAppeared, delay: 0.05, reduceMotion: reduceMotion)
    }

    private var trendIconName: String {
        if viewModel.spendingTrendPercent > 0 { return "arrow.up.right" }
        if viewModel.spendingTrendPercent < 0 { return "arrow.down.right" }
        return "equal"
    }

    private var trendColor: Color {
        if viewModel.spendingTrendPercent > 0 { return .expenseRed }
        if viewModel.spendingTrendPercent < 0 { return .incomeGreen }
        return .secondary
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipView(
                    label: "All",
                    isSelected: viewModel.selectedTypeFilter == nil
                ) {
                    viewModel.selectedTypeFilter = nil
                }

                FilterChipView(
                    label: "Income",
                    isSelected: viewModel.selectedTypeFilter == .income
                ) {
                    viewModel.selectedTypeFilter = .income
                }

                FilterChipView(
                    label: "Expense",
                    isSelected: viewModel.selectedTypeFilter == .expense
                ) {
                    viewModel.selectedTypeFilter = .expense
                }

                Divider()
                    .frame(height: 20)

                Menu {
                    Button("All Categories") {
                        viewModel.selectedCategoryFilter = nil
                    }
                    Divider()
                    ForEach(Category.allCases) { category in
                        Button {
                            viewModel.selectedCategoryFilter = category
                        } label: {
                            Label(category.title, systemImage: category.iconName)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedCategoryFilter?.title ?? "Category")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .foregroundStyle(viewModel.selectedCategoryFilter != nil ? .white : .primary)
                    .background(viewModel.selectedCategoryFilter != nil ? Color.appPrimary : Color.cardBackground)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        List {
            // Summary card & filters scroll with the list
            Section {
                summaryCard
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geo.frame(in: .global).minY
                            )
                        }
                    )

                filterChips
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.groupedTransactions, id: \.key) { group in
                Section {
                    ForEach(Array(group.transactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(
                            transaction: transaction,
                            appeared: hasAppeared,
                            reduceMotion: reduceMotion
                        )
                        .staggered(index: index, appeared: hasAppeared, reduceMotion: reduceMotion)
                        .onTapGesture {
                            viewModel.transactionToEdit = transaction
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                transactionToDelete = transaction
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.transactionToEdit = transaction
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                } header: {
                    transactionSectionHeader(
                        title: group.key,
                        income: group.sectionIncome,
                        expenses: group.sectionExpenses
                    )
                }
            }
        }
        .listStyle(.plain)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
            let delta = newOffset - lastScrollOffset
            if abs(delta) > 8 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFabVisible = delta > 0
                }
                lastScrollOffset = newOffset
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTypeFilter)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategoryFilter)
    }

    // MARK: - Section Header

    private func transactionSectionHeader(title: String, income: Double, expenses: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("—")
                    .foregroundStyle(.tertiary)

                Group {
                    if income > 0 && expenses > 0 {
                        Text("\(income.asCurrency) earned, \(expenses.asCurrency) spent")
                    } else if expenses > 0 {
                        Text("\(expenses.asCurrency) spent")
                    } else if income > 0 {
                        Text("\(income.asCurrency) earned")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPrimary.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
        .padding(.top, 8)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
    }

    // MARK: - Floating Action Button

    private var fab: some View {
        Button {
            viewModel.showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .offset(y: isFabVisible ? 0 : 100)
        .opacity(isFabVisible ? 1 : 0)
        .animation(
            reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.7),
            value: isFabVisible
        )
        .scaleEntrance(appeared: hasAppeared, delay: 0.4, reduceMotion: reduceMotion)
    }
}

// MARK: - Scroll Offset Tracking

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    TransactionListView()
        .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
}
