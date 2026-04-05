import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding var selectedSegment: Int
    @State private var viewModel = GoalsListViewModel()
    @State private var overallBarProgress: Double = 0
    @State private var selectedGoal: SavingsGoal?
    @State private var quickFundGoal: SavingsGoal?
    @State private var quickFundAmount: String = ""
    @State private var quickFundNote: String = ""
    @State private var fundsTrigger = false
    @FocusState private var quickFundFocused: QuickFundField?

    enum QuickFundField { case amount, note }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    Text("Goals").tag(0)
                    Text("Challenge").tag(1)
                    Text("Budgets").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                Group {
                    switch selectedSegment {
                    case 0:
                        goalsContent
                    case 1:
                        ChallengeView()
                    case 2:
                        BudgetListView()
                    default:
                        goalsContent
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: selectedSegment)
            }
            .onAppear { viewModel.loadGoals(context: context) }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                NavigationStack {
                    AddGoalView(
                        viewModel: AddGoalViewModel(),
                        onSave: { viewModel.loadGoals(context: context) }
                    )
                }
            }
            .navigationDestination(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
            .sheet(item: $quickFundGoal) { goal in
                quickAddFundsSheet(for: goal)
            }
        }
    }

    // MARK: - Goals Content

    private var goalsContent: some View {
        ZStack(alignment: .bottomTrailing) {
            if viewModel.goals.isEmpty {
                EmptyStateView(
                    iconName: "target",
                    title: "No Goals Yet",
                    subtitle: "Set savings goals to track your progress and stay motivated.",
                    actionTitle: "Create Goal"
                ) {
                    viewModel.showingAddGoal = true
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        overallProgressCard

                        if !viewModel.activeGoals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeaderView(title: "Active Goals")

                                GoalCarouselView(
                                    goals: viewModel.activeGoals,
                                    onAddGoal: { viewModel.showingAddGoal = true },
                                    onSelectGoal: { goal in
                                        selectedGoal = goal
                                    },
                                    onQuickAddFunds: { goal in
                                        quickFundGoal = goal
                                    }
                                )
                            }
                        }

                        if !viewModel.completedGoals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeaderView(title: "Completed")

                                ForEach(viewModel.completedGoals) { goal in
                                    NavigationLink {
                                        GoalDetailView(goal: goal)
                                    } label: {
                                        completedGoalCard(goal: goal)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical)
                }
            }

            // FAB
            if !viewModel.goals.isEmpty {
                Button {
                    viewModel.showingAddGoal = true
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
    }

    // MARK: - Overall Progress (Rich Card)

    private var overallProgressCard: some View {
        HStack(spacing: 16) {
            // Mini circular progress
            ZStack {
                Circle()
                    .stroke(Color.appPrimary.opacity(0.15), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: overallBarProgress)
                    .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(viewModel.overallProgress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.appPrimary)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 6) {
                Text("Total Savings")
                    .font(.system(.footnote, design: .serif).weight(.medium))
                    .foregroundStyle(.secondary)

                Text("\(viewModel.totalSaved.asCurrency)")
                    .font(.system(.title3, design: .rounded).weight(.bold))

                Text("of \(viewModel.totalTarget.asCurrency)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("\(viewModel.activeGoals.count) active", systemImage: "flame.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                    if !viewModel.completedGoals.isEmpty {
                        Label("\(viewModel.completedGoals.count) done", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.incomeGreen)
                    }
                }

                Text(motivationalMessage)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundStyle(.appPrimary)
                    .italic()
            }

            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .onAppear {
            if reduceMotion {
                overallBarProgress = viewModel.overallProgress
            } else {
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    overallBarProgress = viewModel.overallProgress
                }
            }
        }
    }

    private var motivationalMessage: String {
        let p = viewModel.overallProgress
        if p == 0 { return "Every journey starts with a single step" }
        if p < 0.25 { return "Great start! Keep the momentum going" }
        if p < 0.5 { return "You're building something amazing" }
        if p < 0.75 { return "Halfway there! Stay consistent" }
        if p < 1.0 { return "Almost there! The finish line is in sight" }
        return "All goals achieved! Time for new dreams"
    }

    // MARK: - Completed Goal Card (Celebration)

    private func completedGoalCard(goal: SavingsGoal) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.incomeGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.incomeGreen)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(goal.name)
                    .font(.subheadline.weight(.medium))

                Text(goal.targetAmount.asCurrency)
                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                    .foregroundStyle(.incomeGreen)
            }

            Spacer()

            // "Achieved" badge
            Text("Achieved")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.incomeGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.incomeGreen.opacity(0.12))
                .clipShape(Capsule())

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.incomeGreen.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Quick Add Funds Sheet

    private func quickAddFundsSheet(for goal: SavingsGoal) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: goal.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.appPrimary)
                    }
                    Text(goal.name)
                        .font(.system(.headline, design: .serif))
                }

                TextField("0.00", text: $quickFundAmount)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.incomeGreen)
                    .focused($quickFundFocused, equals: .amount)

                TextField("Note (optional)", text: $quickFundNote)
                    .focused($quickFundFocused, equals: .note)
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    if let amount = Double(quickFundAmount), amount > 0 {
                        let service = ContributionService()
                        service.addFunds(to: goal, amount: amount, note: quickFundNote, context: context)
                        fundsTrigger.toggle()
                        quickFundAmount = ""
                        quickFundNote = ""
                        quickFundGoal = nil
                        viewModel.loadGoals(context: context)
                    }
                } label: {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(Double(quickFundAmount) ?? 0 <= 0)

                Spacer()
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        quickFundAmount = ""
                        quickFundNote = ""
                        quickFundGoal = nil
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { quickFundFocused = nil }
                }
            }
            .sensoryFeedback(.success, trigger: fundsTrigger)
        }
        .presentationDetents([.height(340)])
    }
}
