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
    @State private var showingCustomDatePicker = false

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
            .sheet(isPresented: $showingCustomDatePicker) {
                customDatePickerSheet
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(spacing: 10) {
            // MARK: Income & Expenses row
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.incomeGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.monthlyIncome.asCurrency)
                            .font(.system(.callout, design: .rounded).weight(.bold))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: viewModel.monthlyIncome)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.expenseRed)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expenses")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(viewModel.monthlyExpenses.asCurrency)
                            .font(.system(.callout, design: .rounded).weight(.bold))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: viewModel.monthlyExpenses)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: Spending ratio bar
            GeometryReader { geo in
                let total = viewModel.monthlyIncome + viewModel.monthlyExpenses
                let expenseRatio = total > 0 ? viewModel.monthlyExpenses / total : 0
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.incomeGreen.opacity(0.18))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.expenseRed.opacity(0.7), .expenseRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * expenseRatio)
                        .animation(.easeInOut(duration: 0.5), value: expenseRatio)
                }
            }
            .frame(height: 5)

            // MARK: Net Balance & Trend row
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Net Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.netBalance.asCurrency)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(viewModel.netBalance >= 0 ? .incomeGreen : .expenseRed)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.netBalance)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: trendIconName)
                        .font(.system(size: 11, weight: .bold))
                    Text("vs last mo.")
                        .font(.system(.caption2, design: .rounded))
                    Text(String(format: "%.0f%%", abs(viewModel.spendingTrendPercent)))
                        .font(.system(.caption, design: .rounded).weight(.bold))
                }
                .foregroundStyle(trendColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(trendColor.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.08), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 16)
        .padding(.top, 4)
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
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChipView(
                        label: "All",
                        isSelected: viewModel.selectedTypeFilter == nil
                    ) {
                        viewModel.selectedTypeFilter = nil
                    }
                    .id("filter_all")

                    FilterChipView(
                        label: "Income",
                        isSelected: viewModel.selectedTypeFilter == .income
                    ) {
                        viewModel.selectedTypeFilter = .income
                    }
                    .id("filter_income")

                    FilterChipView(
                        label: "Expense",
                        isSelected: viewModel.selectedTypeFilter == .expense
                    ) {
                        viewModel.selectedTypeFilter = .expense
                    }
                    .id("filter_expense")

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
                        HStack(spacing: AppSpacing.xs) {
                            Text(viewModel.selectedCategoryFilter?.title ?? "Category")
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.selectedCategoryFilter != nil ? .white : .primary)
                        .background(viewModel.selectedCategoryFilter != nil ? Color.appPrimary : Color.cardBackground)
                        .clipShape(Capsule())
                    }
                    .id("filter_category")

                    Divider()
                        .frame(height: 20)

                    Menu {
                        ForEach(DateFilter.allCases) { filter in
                            Button {
                                if filter == .custom {
                                    showingCustomDatePicker = true
                                }
                                viewModel.selectedDateFilter = filter
                            } label: {
                                HStack {
                                    Text(filter.rawValue)
                                    if viewModel.selectedDateFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(dateFilterLabel)
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.selectedDateFilter != .all ? .white : .primary)
                        .background(viewModel.selectedDateFilter != .all ? Color.appPrimary : Color.cardBackground)
                        .clipShape(Capsule())
                    }
                    .id("filter_date")
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 4)
            .onChange(of: viewModel.selectedTypeFilter) {
                withAnimation {
                    if let type = viewModel.selectedTypeFilter {
                        proxy.scrollTo("filter_\(type.rawValue.lowercased())", anchor: .center)
                    } else {
                        proxy.scrollTo("filter_all", anchor: .center)
                    }
                }
            }
            .onChange(of: viewModel.selectedCategoryFilter) {
                withAnimation {
                    proxy.scrollTo("filter_category", anchor: .center)
                }
            }
            .onChange(of: viewModel.selectedDateFilter) {
                withAnimation {
                    proxy.scrollTo("filter_date", anchor: .center)
                }
            }
        }
    }

    private var dateFilterLabel: String {
        switch viewModel.selectedDateFilter {
        case .all:
            return "Date"
        case .custom:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: viewModel.customDateFrom)) – \(formatter.string(from: viewModel.customDateTo))"
        default:
            return viewModel.selectedDateFilter.rawValue
        }
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
                .headerProminence(.increased)
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedDateFilter)
    }

    // MARK: - Section Header

    private func transactionSectionHeader(title: String, income: Double, expenses: Double) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(.label))

                Text("—")
                    .foregroundColor(Color(.label))

                Group {
                    if income > 0 && expenses > 0 {
                        Text("\(income.asCurrency) earned, \(expenses.asCurrency) spent")
                    } else if expenses > 0 {
                        Text("\(expenses.asCurrency) spent")
                    } else if income > 0 {
                        Text("\(income.asCurrency) earned")
                    }
                }
                .font(.subheadline.weight(.regular))
                .foregroundColor(Color(.label))

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
        .padding(.top, 4)
        .textCase(nil)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 2, trailing: 16))
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

    // MARK: - Custom Date Picker Sheet

    private var customDatePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "From",
                    selection: $viewModel.customDateFrom,
                    in: ...viewModel.customDateTo,
                    displayedComponents: .date
                )

                DatePicker(
                    "To",
                    selection: $viewModel.customDateTo,
                    in: viewModel.customDateFrom...,
                    displayedComponents: .date
                )

                Spacer()
            }
            .padding()
            .navigationTitle("Custom Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingCustomDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
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
