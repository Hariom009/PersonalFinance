import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = BudgetViewModel()
    @FocusState private var limitFieldFocused: Bool
    @State private var addTrigger = false
    @State private var budgetToDelete: Budget? = nil
    @State private var hasAppeared = false

    var body: some View {
        ScrollView {
            if viewModel.budgets.isEmpty {
                EmptyStateView(
                    iconName: "chart.bar.doc.horizontal",
                    title: "No Budgets",
                    subtitle: "Set monthly spending limits for your categories to stay on track.",
                    actionTitle: "Add Budget"
                ) {
                    viewModel.showingAddBudget = true
                }
                .padding(.top, 40)
            } else {
                VStack(spacing: 16) {
                    // Budget Summary Card
                    budgetSummaryCard

                    // Needs Attention
                    if !viewModel.needsAttentionBudgets.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "Needs Attention")

                            ForEach(viewModel.needsAttentionBudgets) { budget in
                                NeedsAttentionCard(
                                    category: budget.category,
                                    spent: viewModel.spentFor(budget),
                                    limit: budget.monthlyLimit
                                )
                                .contextMenu {
                                    Button {
                                        viewModel.startEditing(budget)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        budgetToDelete = budget
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    // All Budgets Grid
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "All Budgets")

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(Array(viewModel.budgets.enumerated()), id: \.element.id) { index, budget in
                                BudgetGridCard(
                                    category: budget.category,
                                    spent: viewModel.spentFor(budget),
                                    limit: budget.monthlyLimit
                                )
                                .contextMenu {
                                    Button {
                                        viewModel.startEditing(budget)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        budgetToDelete = budget
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .staggered(index: index, appeared: hasAppeared, reduceMotion: reduceMotion)
                            }
                        }
                    }

                    Button {
                        viewModel.showingAddBudget = true
                    } label: {
                        Label("Add Budget", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical)
            }
        }
        .onAppear {
            viewModel.loadData(context: context)
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    hasAppeared = true
                }
            } else {
                hasAppeared = true
            }
        }
        .sheet(isPresented: $viewModel.showingAddBudget) {
            addBudgetSheet
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.budgetToEdit != nil },
                set: { if !$0 { viewModel.budgetToEdit = nil; viewModel.selectedCategory = nil; viewModel.limitText = "" } }
            )
        ) {
            editBudgetSheet
        }
        .confirmationDialog(
            "Delete this budget?",
            isPresented: Binding(
                get: { budgetToDelete != nil },
                set: { if !$0 { budgetToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let budget = budgetToDelete {
                    viewModel.deleteBudget(budget, context: context)
                    budgetToDelete = nil
                }
            }
        } message: {
            Text("This will remove the budget limit for this category.")
        }
        .sensoryFeedback(.success, trigger: addTrigger)
    }

    // MARK: - Budget Summary Card

    private var budgetSummaryCard: some View {
        VStack(spacing: 10) {
            BudgetFillCard(
                statusColor: viewModel.overallStatusColor,
                progress: min(viewModel.totalUsagePercent, 1.0),
                percent: viewModel.totalUsagePercent,
                spent: viewModel.totalSpent,
                limit: viewModel.totalLimit
            )

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(viewModel.overallStatusColor)

                Text("You have \(viewModel.totalRemaining.asCurrency) remaining this month")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Edit Budget Sheet

    private var editBudgetSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit Budget")
                    .font(.title3.bold())

                if let budget = viewModel.budgetToEdit {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(budget.category.color.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: budget.category.iconName)
                                .font(.system(size: 18))
                                .foregroundStyle(budget.category.color)
                        }

                        Text(budget.category.title)
                            .font(.headline)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Limit")
                        .font(.headline)

                    TextField("0.00", text: $viewModel.limitText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .focused($limitFieldFocused)
                        .padding(.vertical, 12)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    viewModel.updateBudget(context: context)
                    addTrigger.toggle()
                } label: {
                    Text("Update Budget")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.limitValue <= 0)

                Spacer()
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.budgetToEdit = nil
                        viewModel.selectedCategory = nil
                        viewModel.limitText = ""
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { limitFieldFocused = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Add Budget Sheet

    private var addBudgetSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Set Budget")
                    .font(.title3.bold())

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12) {
                        ForEach(Category.expenseCategories) { category in
                            let isSelected = viewModel.selectedCategory == category

                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(category.color.opacity(isSelected ? 1.0 : 0.15))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: category.iconName)
                                        .font(.system(size: 18))
                                        .foregroundStyle(isSelected ? .white : category.color)
                                }

                                Text(category.title)
                                    .font(.caption)
                                    .foregroundStyle(isSelected ? .primary : .secondary)
                            }
                            .onTapGesture {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Limit")
                        .font(.headline)

                    TextField("0.00", text: $viewModel.limitText)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .focused($limitFieldFocused)
                        .padding(.vertical, 12)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    viewModel.addBudget(context: context)
                    addTrigger.toggle()
                    viewModel.showingAddBudget = false
                } label: {
                    Text("Set Budget")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isAddValid)

                Spacer()
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showingAddBudget = false }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { limitFieldFocused = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
