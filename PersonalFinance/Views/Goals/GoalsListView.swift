import SwiftUI
import SwiftData

struct GoalsListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = GoalsListViewModel()
    @State private var overallBarProgress: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $viewModel.selectedSegment) {
                    Text("Goals").tag(0)
                    Text("Challenge").tag(1)
                    Text("Budgets").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                Group {
                    switch viewModel.selectedSegment {
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
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedSegment)
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

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.activeGoals) { goal in
                                            NavigationLink {
                                                GoalDetailView(goal: goal)
                                            } label: {
                                                GoalCarouselCardView(
                                                    goal: goal,
                                                    depth: .front
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }

                        if !viewModel.completedGoals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeaderView(title: "Completed")

                                ForEach(viewModel.completedGoals) { goal in
                                    NavigationLink {
                                        GoalDetailView(goal: goal)
                                    } label: {
                                        goalCard(goal: goal, completed: true)
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

    // MARK: - Overall Progress

    private var overallProgressCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Total Savings")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(viewModel.totalSaved.asCurrency) of \(viewModel.totalTarget.asCurrency)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.incomeGreen.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.incomeGreen)
                        .frame(width: geo.size.width * overallBarProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

    // MARK: - Goal Card

    private func goalCard(goal: SavingsGoal, completed: Bool = false) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(completed ? Color.incomeGreen.opacity(0.15) : Color.decorativeIconBg)
                    .frame(width: 44, height: 44)

                Image(systemName: completed ? "checkmark.circle.fill" : goal.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(completed ? .incomeGreen : .secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(goal.name)
                    .font(.subheadline.weight(.medium))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.incomeGreen.opacity(0.15))
                            .frame(height: 6)
                        Capsule()
                            .fill(Color.incomeGreen)
                            .frame(width: geo.size.width * goal.progress, height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(goal.currentAmount.asCurrency) of \(goal.targetAmount.asCurrency)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)

                    Spacer()

                    if !completed {
                        let days = Calendar.current.dateComponents([.day], from: .now, to: goal.deadline).day ?? 0
                        Text("\(max(days, 0))d left")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
