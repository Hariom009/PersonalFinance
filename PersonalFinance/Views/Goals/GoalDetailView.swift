import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: GoalDetailViewModel

    @FocusState private var focusedFundsField: FundsField?
    @State private var showDeleteConfirmation = false
    @State private var fundsTrigger = false
    @State private var ringPulse = false

    enum FundsField { case amount, note }

    init(goal: SavingsGoal) {
        _viewModel = State(initialValue: GoalDetailViewModel(goal: goal))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressSection
                statsRow
                daysRemainingBadge
                addFundsButton
                contributionsSection
                editDeleteSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadContributions(context: context) }
        .sheet(isPresented: $viewModel.showingAddFunds) {
            addFundsSheet
        }
        .sheet(isPresented: $viewModel.showingEditGoal) {
            NavigationStack {
                AddGoalView(
                    viewModel: AddGoalViewModel(goal: viewModel.goal),
                    onSave: { viewModel.loadContributions(context: context) }
                )
            }
        }
    }

    // MARK: - Progress Ring

    private var progressSection: some View {
        CircularProgressView(progress: viewModel.goal.progress)
            .scaleEffect(ringPulse ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: ringPulse)
            .padding(.top, 8)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(title: "Saved", value: viewModel.goal.currentAmount.asCurrency)
            Divider().frame(height: 36)
            statItem(title: "Remaining", value: viewModel.remainingAmount.asCurrency)
            Divider().frame(height: 36)
            statItem(title: "Per Day", value: viewModel.dailyTarget.asCurrency)
        }
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Days Remaining

    private var daysRemainingBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.goal.isCompleted ? "checkmark.circle.fill" : "calendar")
                .foregroundStyle(viewModel.goal.isCompleted ? .incomeGreen : .secondary)

            Text(viewModel.goal.isCompleted ? "Goal Completed!" : "\(viewModel.daysRemaining) days remaining")
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.cardBackground)
        .clipShape(Capsule())
    }

    // MARK: - Add Funds

    private var addFundsButton: some View {
        Button {
            viewModel.showingAddFunds = true
        } label: {
            Label("Add Funds", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.goal.isCompleted)
    }

    // MARK: - Contributions

    private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Contributions")

            if viewModel.contributions.isEmpty {
                Text("No contributions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.contributions.enumerated()), id: \.element.id) { index, contribution in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.incomeGreen.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.incomeGreen)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("+\(contribution.amount.asCurrency)")
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                    .foregroundStyle(.incomeGreen)

                                Text(contribution.note.isEmpty ? "Contribution" : contribution.note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(contribution.date.formattedRelative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)

                        if index < viewModel.contributions.count - 1 {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Edit / Delete

    private var editDeleteSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.showingEditGoal = true
            } label: {
                Text("Edit Goal")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Delete Goal")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .confirmationDialog(
                "Delete this goal?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteGoal(context: context)
                    dismiss()
                }
            } message: {
                Text("This will permanently remove the goal and all contributions.")
            }
        }
    }

    // MARK: - Add Funds Sheet

    private var addFundsSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add Funds")
                    .font(.system(.title3, design: .serif).bold())

                TextField("0.00", text: $viewModel.fundsAmount)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.incomeGreen)
                    .focused($focusedFundsField, equals: .amount)

                TextField("Note (optional)", text: $viewModel.fundsNote)
                    .focused($focusedFundsField, equals: .note)
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    viewModel.addFunds(context: context)
                    fundsTrigger.toggle()
                    viewModel.showingAddFunds = false
                    ringPulse = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        ringPulse = false
                    }
                } label: {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isFundsValid)

                Spacer()
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showingAddFunds = false }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedFundsField = nil }
                }
            }
            .sensoryFeedback(.success, trigger: fundsTrigger)
        }
        .presentationDetents([.height(320)])
    }
}
