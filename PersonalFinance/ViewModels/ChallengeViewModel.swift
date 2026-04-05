import Foundation
import SwiftData
import SwiftUI

// MARK: - Challenge Preset

enum ChallengePreset: CaseIterable, Identifiable {
    case week, twoWeeks, month, custom

    var id: String { label }

    var label: String {
        switch self {
        case .week: return "7 days"
        case .twoWeeks: return "14 days"
        case .month: return "30 days"
        case .custom: return "Custom"
        }
    }

    var days: Int? {
        switch self {
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .custom: return nil
        }
    }
}

@Observable
final class ChallengeViewModel {
    var challenge: NoSpendChallenge? = nil
    var transactions: [Transaction] = []
    var targetDaysText: String = "30"
    var selectedPreset: ChallengePreset? = .month

    private let challengeService = ChallengeService()
    private let transactionService = TransactionService()

    // MARK: - Computed

    var hasActiveChallenge: Bool {
        challenge?.isActive == true
    }

    var currentStreak: Int {
        guard let challenge else { return 0 }
        return challengeService.computeStreak(challenge: challenge, transactions: transactions)
    }

    var calendarDays: [DayStatus] {
        guard let challenge else { return [] }
        return challengeService.computeCalendar(challenge: challenge, transactions: transactions)
    }

    var personalBest: Int {
        challenge?.personalBestStreak ?? 0
    }

    var targetDays: Int {
        challenge?.targetDays ?? (Int(targetDaysText) ?? 30)
    }

    var dayNumber: Int {
        guard let challenge else { return 0 }
        return Calendar.current.dateComponents([.day], from: challenge.startDate, to: .now).day ?? 0
    }

    var motivationalMessage: String? {
        challengeService.motivationalMessage(for: currentStreak)
    }

    var exemptCategories: [Category] {
        challenge?.exemptCategories ?? []
    }

    var progressFraction: Double {
        guard targetDays > 0 else { return 0 }
        return min(Double(dayNumber) / Double(targetDays), 1.0)
    }

    var personalBestFraction: Double {
        guard targetDays > 0 else { return 0 }
        return min(Double(personalBest) / Double(targetDays), 1.0)
    }

    var difficultyLabel: String {
        let days = Int(targetDaysText) ?? 30
        switch days {
        case ...7: return "Easy"
        case 8...14: return "Medium"
        case 15...30: return "Hard"
        default: return "Beast Mode"
        }
    }

    var difficultyColor: Color {
        let days = Int(targetDaysText) ?? 30
        switch days {
        case ...7: return .incomeGreen
        case 8...14: return .orange
        case 15...30: return .expenseRed
        default: return .purple
        }
    }

    // MARK: - Methods

    func selectPreset(_ preset: ChallengePreset) {
        selectedPreset = preset
        if let days = preset.days {
            targetDaysText = "\(days)"
        }
    }

    func loadData(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<NoSpendChallenge>(
                predicate: #Predicate<NoSpendChallenge> { $0.isActive == true }
            )
            challenge = try context.fetch(descriptor).first
            transactions = try transactionService.fetch(context: context)
        } catch {
            challenge = nil
            transactions = []
        }
    }

    func startChallenge(context: ModelContext) {
        let days = Int(targetDaysText) ?? 30
        let newChallenge = NoSpendChallenge(
            startDate: .now,
            targetDays: max(days, 1),
            exemptCategoriesRaw: [Category.bills.rawValue],
            isActive: true,
            personalBestStreak: challenge?.personalBestStreak ?? 0
        )
        context.insert(newChallenge)
        try? context.save()
        challenge = newChallenge
    }

    func endChallenge(context: ModelContext) {
        guard let challenge else { return }
        let streak = currentStreak
        if streak > challenge.personalBestStreak {
            challenge.personalBestStreak = streak
        }
        challenge.isActive = false
        try? context.save()
        self.challenge = nil
    }

    func toggleExemptCategory(_ category: Category, context: ModelContext) {
        guard let challenge else { return }
        if challenge.isExempt(category) {
            challenge.removeExemptCategory(category)
        } else {
            challenge.addExemptCategory(category)
        }
        try? context.save()
    }
}
