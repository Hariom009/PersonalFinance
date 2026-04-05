import Foundation
import SwiftData

@Model
final class NoSpendChallenge: Identifiable {
    var id: UUID
    var startDate: Date
    var targetDays: Int
    var exemptCategoriesRaw: [String]
    var isActive: Bool
    var personalBestStreak: Int

    var exemptCategories: [Category] {
        exemptCategoriesRaw.compactMap { Category(rawValue: $0) }
    }

    func isExempt(_ category: Category) -> Bool {
        exemptCategoriesRaw.contains(category.rawValue)
    }

    func addExemptCategory(_ category: Category) {
        if !exemptCategoriesRaw.contains(category.rawValue) {
            exemptCategoriesRaw.append(category.rawValue)
        }
    }

    func removeExemptCategory(_ category: Category) {
        exemptCategoriesRaw.removeAll { $0 == category.rawValue }
    }

    init(
        id: UUID = UUID(),
        startDate: Date = .now,
        targetDays: Int = 30,
        exemptCategoriesRaw: [String] = [],
        isActive: Bool = true,
        personalBestStreak: Int = 0
    ) {
        self.id = id
        self.startDate = startDate
        self.targetDays = targetDays
        self.exemptCategoriesRaw = exemptCategoriesRaw
        self.isActive = isActive
        self.personalBestStreak = personalBestStreak
    }
}
