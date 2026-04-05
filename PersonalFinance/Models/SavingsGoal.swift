import Foundation
import SwiftUI
import SwiftData

enum GoalStatus {
    case onTrack, behind, atRisk, overdue, completed

    var label: String {
        switch self {
        case .onTrack: "On Track"
        case .behind: "Behind"
        case .atRisk: "At Risk"
        case .overdue: "Overdue"
        case .completed: "Achieved"
        }
    }

    var color: Color {
        switch self {
        case .onTrack: .green
        case .behind: .orange
        case .atRisk: .red
        case .overdue: .red
        case .completed: .green
        }
    }

    var icon: String {
        switch self {
        case .onTrack: "checkmark.circle.fill"
        case .behind: "exclamationmark.triangle.fill"
        case .atRisk: "flame.fill"
        case .overdue: "clock.badge.exclamationmark"
        case .completed: "trophy.fill"
        }
    }
}

@Model
final class SavingsGoal {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date
    var iconName: String

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    var isCompleted: Bool {
        currentAmount >= targetAmount
    }

    var daysRemaining: Int {
        let days = Calendar.current.dateComponents([.day], from: .now, to: deadline).day ?? 0
        return max(days, 0)
    }

    var status: GoalStatus {
        if isCompleted { return .completed }

        let days = Calendar.current.dateComponents([.day], from: .now, to: deadline).day ?? 0
        if days < 0 { return .overdue }

        if days <= 7 && progress < 0.7 { return .atRisk }
        if days <= 30 && progress < 0.5 { return .atRisk }
        if days <= 30 && progress >= 0.7 { return .onTrack }
        if days > 30 && progress >= 0.25 { return .onTrack }

        return .behind
    }

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        deadline: Date,
        iconName: String = "target"
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.iconName = iconName
    }
}
