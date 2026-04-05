import Foundation

struct DayStatus: Identifiable {
    let id = UUID()
    let date: Date
    let didSpend: Bool
    let isToday: Bool
    let isFuture: Bool
}

struct ChallengeService {
    func computeStreak(challenge: NoSpendChallenge, transactions: [Transaction]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date.now.startOfDay

        while checkDate >= challenge.startDate.startOfDay {
            if didSpendNonExempt(on: checkDate, challenge: challenge, transactions: transactions, calendar: calendar) {
                break
            }
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streak
    }

    func computeCalendar(challenge: NoSpendChallenge, transactions: [Transaction]) -> [DayStatus] {
        let calendar = Calendar.current
        let startDay = challenge.startDate.startOfDay
        let today = Date.now.startOfDay
        let endDay = calendar.date(byAdding: .day, value: challenge.targetDays - 1, to: startDay) ?? today

        var days: [DayStatus] = []
        var currentDay = startDay

        while currentDay <= endDay {
            let isFuture = currentDay > today
            let isToday = calendar.isDateInToday(currentDay)
            let didSpend = isFuture ? false : didSpendNonExempt(
                on: currentDay,
                challenge: challenge,
                transactions: transactions,
                calendar: calendar
            )

            days.append(DayStatus(
                date: currentDay,
                didSpend: didSpend,
                isToday: isToday,
                isFuture: isFuture
            ))

            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }
            currentDay = next
        }

        return days
    }

    func motivationalMessage(for streakDays: Int) -> String? {
        switch streakDays {
        case 3: return "You're building a habit!"
        case 7: return "One whole week — unstoppable!"
        case 14: return "Two weeks! Your wallet thanks you!"
        case 30: return "Savings legend status!"
        case _ where streakDays > 0 && streakDays % 10 == 0:
            return "\(streakDays) days strong!"
        default: return nil
        }
    }

    // MARK: - Private

    private func didSpendNonExempt(
        on date: Date,
        challenge: NoSpendChallenge,
        transactions: [Transaction],
        calendar: Calendar
    ) -> Bool {
        let dayTransactions = transactions.filter { transaction in
            transaction.type == .expense && calendar.isDate(transaction.date, inSameDayAs: date)
        }

        guard !dayTransactions.isEmpty else { return false }

        return dayTransactions.contains { transaction in
            !challenge.isExempt(transaction.category)
        }
    }
}
