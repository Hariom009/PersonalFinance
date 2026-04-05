import Foundation
import SwiftData

struct MockDataService {
    static func populateIfEmpty(context: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        guard count == 0 else { return }

        let transactions = generateSampleTransactions()
        for transaction in transactions {
            context.insert(transaction)
        }
        let goals = generateSampleGoals()
        for goal in goals {
            context.insert(goal)
        }
        for contribution in generateSampleContributions(goals: goals) {
            context.insert(contribution)
        }
        if let challenge = generateSampleChallenge() {
            context.insert(challenge)
        }
        for budget in generateSampleBudgets() {
            context.insert(budget)
        }
    }

    static func generateSampleTransactions() -> [Transaction] {
        var transactions: [Transaction] = []
        let calendar = Calendar.current

        func date(daysAgo: Int) -> Date {
            calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
        }

        // Salary - once a month
        transactions.append(Transaction(amount: 5000, type: .income, category: .salary, date: date(daysAgo: 1), note: "Monthly salary"))

        // Freelance - a couple times
        transactions.append(Transaction(amount: 850, type: .income, category: .freelance, date: date(daysAgo: 5), note: "App design project"))
        transactions.append(Transaction(amount: 1200, type: .income, category: .freelance, date: date(daysAgo: 18), note: "Consulting work"))

        // Investment return
        transactions.append(Transaction(amount: 320, type: .income, category: .investment, date: date(daysAgo: 10), note: "Dividend payout"))

        // Gift
        transactions.append(Transaction(amount: 200, type: .income, category: .gift, date: date(daysAgo: 22), note: "Birthday gift"))

        // Food expenses - daily
        let foodItems = ["Groceries", "Coffee shop", "Lunch out", "Dinner with friends", "Snacks", "Takeaway pizza", "Smoothie bar"]
        let foodAmounts: [Double] = [45, 8, 22, 55, 12, 28, 15]
        for i in 0..<7 {
            transactions.append(Transaction(amount: foodAmounts[i], type: .expense, category: .food, date: date(daysAgo: i * 3), note: foodItems[i]))
        }

        // Transport
        let transportItems = ["Uber ride", "Gas station", "Bus pass", "Parking fee", "Train ticket"]
        let transportAmounts: [Double] = [18, 55, 30, 8, 24]
        for i in 0..<5 {
            transactions.append(Transaction(amount: transportAmounts[i], type: .expense, category: .transport, date: date(daysAgo: i * 5 + 1), note: transportItems[i]))
        }

        // Entertainment
        transactions.append(Transaction(amount: 15, type: .expense, category: .entertainment, date: date(daysAgo: 2), note: "Netflix subscription"))
        transactions.append(Transaction(amount: 45, type: .expense, category: .entertainment, date: date(daysAgo: 7), note: "Movie tickets"))
        transactions.append(Transaction(amount: 80, type: .expense, category: .entertainment, date: date(daysAgo: 14), note: "Concert tickets"))

        // Bills
        transactions.append(Transaction(amount: 120, type: .expense, category: .bills, date: date(daysAgo: 3), note: "Electricity bill", isRecurring: true))
        transactions.append(Transaction(amount: 65, type: .expense, category: .bills, date: date(daysAgo: 3), note: "Internet bill", isRecurring: true))
        transactions.append(Transaction(amount: 45, type: .expense, category: .bills, date: date(daysAgo: 8), note: "Phone plan", isRecurring: true))

        // Shopping
        transactions.append(Transaction(amount: 89, type: .expense, category: .shopping, date: date(daysAgo: 4), note: "New sneakers"))
        transactions.append(Transaction(amount: 35, type: .expense, category: .shopping, date: date(daysAgo: 12), note: "Book order"))
        transactions.append(Transaction(amount: 150, type: .expense, category: .shopping, date: date(daysAgo: 20), note: "Electronics accessory"))

        // Health
        transactions.append(Transaction(amount: 40, type: .expense, category: .health, date: date(daysAgo: 6), note: "Gym membership", isRecurring: true))
        transactions.append(Transaction(amount: 25, type: .expense, category: .health, date: date(daysAgo: 15), note: "Vitamins"))

        // Education
        transactions.append(Transaction(amount: 49, type: .expense, category: .education, date: date(daysAgo: 9), note: "Online course"))
        transactions.append(Transaction(amount: 30, type: .expense, category: .education, date: date(daysAgo: 25), note: "Textbook"))

        return transactions
    }

    static func generateSampleGoals() -> [SavingsGoal] {
        let calendar = Calendar.current
        return [
            SavingsGoal(
                name: "Emergency Fund",
                targetAmount: 10000,
                currentAmount: 4500,
                deadline: calendar.date(byAdding: .month, value: 6, to: .now) ?? .now,
                iconName: "shield.fill"
            ),
            SavingsGoal(
                name: "Vacation",
                targetAmount: 3000,
                currentAmount: 1200,
                deadline: calendar.date(byAdding: .month, value: 3, to: .now) ?? .now,
                iconName: "airplane"
            ),
            SavingsGoal(
                name: "New Laptop",
                targetAmount: 2000,
                currentAmount: 800,
                deadline: calendar.date(byAdding: .month, value: 2, to: .now) ?? .now,
                iconName: "laptopcomputer"
            ),
            SavingsGoal(
                name: "Online Course",
                targetAmount: 500,
                currentAmount: 350,
                deadline: calendar.date(byAdding: .month, value: 1, to: .now) ?? .now,
                iconName: "book.fill"
            ),
        ]
    }

    static func generateSampleContributions(goals: [SavingsGoal]) -> [GoalContribution] {
        var contributions: [GoalContribution] = []
        let calendar = Calendar.current

        for goal in goals {
            let amounts: [(Double, Int, String)] = [
                (goal.currentAmount * 0.4, 20, "Initial deposit"),
                (goal.currentAmount * 0.3, 12, "Monthly savings"),
                (goal.currentAmount * 0.2, 5, "Extra deposit"),
                (goal.currentAmount * 0.1, 2, "Top up"),
            ]
            for (amount, daysAgo, note) in amounts {
                contributions.append(GoalContribution(
                    goalId: goal.id,
                    amount: amount,
                    date: calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now,
                    note: note
                ))
            }
        }

        return contributions
    }

    static func generateSampleChallenge() -> NoSpendChallenge? {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -5, to: .now) else { return nil }

        return NoSpendChallenge(
            startDate: startDate,
            targetDays: 30,
            exemptCategoriesRaw: [Category.bills.rawValue],
            isActive: true,
            personalBestStreak: 12
        )
    }

    static func generateSampleBudgets() -> [Budget] {
        [
            Budget(category: .food, monthlyLimit: 300),
            Budget(category: .entertainment, monthlyLimit: 100),
            Budget(category: .shopping, monthlyLimit: 200),
            Budget(category: .transport, monthlyLimit: 150),
        ]
    }
}
