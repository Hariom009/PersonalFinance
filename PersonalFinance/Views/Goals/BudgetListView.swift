import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = BudgetViewModel()
    @FocusState private var limitFieldFocused: Bool
    @State private var addTrigger = false
    @State private var budgetToDelete: Budget? = nil

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
                VStack(spacing: 12) {
                    ForEach(viewModel.budgets) { budget in
                        BudgetProgressRow(
                            category: budget.category,
                            spent: viewModel.spentFor(budget),
                            limit: budget.monthlyLimit
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                budgetToDelete = budget
                            } label: {
                                Label("Delete", systemImage: "trash")
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
        .onAppear { viewModel.loadData(context: context) }
        .sheet(isPresented: $viewModel.showingAddBudget) {
            addBudgetSheet
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
                                    .font(.caption2)
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
