import SwiftUI
import SwiftData

struct ChallengeView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ChallengeViewModel()
    @FocusState private var targetDaysFocused: Bool
    @State private var showEndConfirmation = false

    var body: some View {
        ScrollView {
            if viewModel.hasActiveChallenge {
                activeChallengeContent
            } else {
                startChallengeContent
            }
        }
        .onAppear { viewModel.loadData(context: context) }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { targetDaysFocused = false }
            }
        }
    }

    // MARK: - Start Challenge

    private var startChallengeContent: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text("No-Spend Challenge")
                .font(.title.bold())

            Text("See how many days you can go without unnecessary spending")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("Target Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("30", text: $viewModel.targetDaysText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($targetDaysFocused)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                viewModel.startChallenge(context: context)
            } label: {
                Text("Start Challenge")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.orange)
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }

    // MARK: - Active Challenge

    private var activeChallengeContent: some View {
        VStack(spacing: 20) {
            streakHeroCard
            statsRow
            calendarSection
            exemptCategoriesSection
            endChallengeButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
    }

    // MARK: - Streak Hero

    private var streakHeroCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)

            Text("\(viewModel.currentStreak)")
                .font(.system(size: 64, weight: .bold, design: .rounded))

            Text("day streak")
                .font(.title3)
                .foregroundStyle(.secondary)

            if let message = viewModel.motivationalMessage {
                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            LinearGradient(
                colors: [.orange.opacity(0.15), .red.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            challengeStatCard(title: "Best", value: "\(viewModel.personalBest)", icon: "trophy.fill")
            challengeStatCard(title: "Target", value: "\(viewModel.targetDays)", icon: "flag.fill")
            challengeStatCard(title: "Day", value: "\(viewModel.dayNumber)", icon: "calendar")
        }
    }

    private func challengeStatCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.orange)

            Text(value)
                .font(.headline.weight(.bold))

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Your Journey")

            StreakCalendarView(days: viewModel.calendarDays)

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(Color.incomeGreen).frame(width: 10, height: 10)
                    Text("No spend").font(.caption2).foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Circle().fill(Color.expenseRed.opacity(0.7)).frame(width: 10, height: 10)
                    Text("Spent").font(.caption2).foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Circle().strokeBorder(.secondary.opacity(0.3), lineWidth: 1).frame(width: 10, height: 10)
                    Text("Future").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Exempt Categories

    private var exemptCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Exempt Categories", subtitle: "These don't break your streak")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                ForEach(Category.expenseCategories) { category in
                    let isExempt = viewModel.exemptCategories.contains(category)

                    HStack(spacing: 4) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 12))
                        Text(category.title)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .foregroundStyle(isExempt ? .incomeGreen : .secondary)
                    .background(isExempt ? Color.incomeGreen.opacity(0.12) : Color.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(isExempt ? Color.incomeGreen.opacity(0.3) : .clear, lineWidth: 1)
                    )
                    .onTapGesture {
                        viewModel.toggleExemptCategory(category, context: context)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - End Challenge

    private var endChallengeButton: some View {
        Button(role: .destructive) {
            showEndConfirmation = true
        } label: {
            Text("End Challenge")
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .padding(.top, 8)
        .confirmationDialog(
            "End this challenge?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Challenge", role: .destructive) {
                viewModel.endChallenge(context: context)
            }
        } message: {
            Text("Your current streak will be saved if it's a personal best.")
        }
    }
}
