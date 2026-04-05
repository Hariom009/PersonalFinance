import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    var showResetConfirmation = false
    var exportURL: URL? = nil

    private let transactionService = TransactionService()

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    func exportTransactions(context: ModelContext) {
        do {
            let transactions = try transactionService.fetch(context: context)
            exportURL = ExportService.generateCSV(transactions: transactions)
        } catch {
            exportURL = nil
        }
    }

    func resetAllData(context: ModelContext) {
        do {
            try context.delete(model: Transaction.self)
            try context.delete(model: SavingsGoal.self)
            try context.delete(model: GoalContribution.self)
            try context.delete(model: NoSpendChallenge.self)
            try context.delete(model: Budget.self)
            try context.save()
        } catch {
            // Silent failure — data may be partially cleared
        }
    }
}
