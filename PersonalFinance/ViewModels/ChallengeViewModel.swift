import Foundation
import SwiftData

@Observable
final class ChallengeViewModel {
    var challenge: NoSpendChallenge? = nil
    var transactions: [Transaction] = []
    var targetDaysText: String = "30"

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

    // MARK: - Methods

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
