import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = TransactionListViewModel()
    @State private var transactionToDelete: Transaction? = nil

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
                    VStack(spacing: 0) {
                        summaryBar
                        filterChips
                        transactionList
                    }
                }

                fab
            }

            .searchable(text: $viewModel.searchText, prompt: "Search transactions...")
            .onAppear { viewModel.fetchTransactions(context: context) }
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

    // MARK: - Monthly Summary Bar

    private var summaryBar: some View {
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
        .padding(.vertical, 10)
        .background(Color.cardBackground)
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
            ForEach(viewModel.groupedTransactions, id: \.key) { group in
                Section(group.key) {
                    ForEach(group.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
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
                                .tint(Color.appPrimary)
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTypeFilter)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedCategoryFilter)
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
    }
}

#Preview {
    TransactionListView()
        .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
}
