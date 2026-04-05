import Foundation
import SwiftData

@Observable
final class AddGoalViewModel {
    var nameText: String = ""
    var amountText: String = ""
    var deadline: Date
    var selectedIcon: String = "target"

    private(set) var isEditing: Bool = false
    private var existingGoal: SavingsGoal? = nil

    private let goalService = GoalService()

    static let availableIcons = [
        "target", "shield.fill", "airplane", "laptopcomputer", "book.fill",
        "house.fill", "car.fill", "heart.fill", "gift.fill", "star.fill",
        "graduationcap.fill", "camera.fill"
    ]

    // MARK: - Computed

    var amountValue: Double {
        Double(amountText) ?? 0
    }

    var isValid: Bool {
        !nameText.trimmingCharacters(in: .whitespaces).isEmpty && amountValue > 0
    }

    var saveButtonTitle: String {
        isEditing ? "Update Goal" : "Create Goal"
    }

    // MARK: - Init

    init() {
        self.deadline = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    }

    init(goal: SavingsGoal) {
        isEditing = true
        existingGoal = goal
        nameText = goal.name
        amountText = String(format: "%.2f", goal.targetAmount)
        deadline = goal.deadline
        selectedIcon = goal.iconName
    }

    // MARK: - Methods

    func save(context: ModelContext) {
        guard isValid else { return }

        if isEditing, let existing = existingGoal {
            goalService.update(
                existing,
                name: nameText,
                targetAmount: amountValue,
                deadline: deadline,
                iconName: selectedIcon
            )
        } else {
            let goal = SavingsGoal(
                name: nameText,
                targetAmount: amountValue,
                deadline: deadline,
                iconName: selectedIcon
            )
            goalService.add(goal, context: context)
        }
        try? context.save()
    }

    func deleteGoal(context: ModelContext) {
        guard let existing = existingGoal else { return }
        goalService.delete(existing, context: context)
        try? context.save()
    }
}
