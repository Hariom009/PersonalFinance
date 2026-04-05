import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case food
    case transport
    case entertainment
    case bills
    case shopping
    case health
    case education
    case salary
    case freelance
    case investment
    case gift
    case other

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .entertainment: "film"
        case .bills: "house.fill"
        case .shopping: "bag.fill"
        case .health: "heart.fill"
        case .education: "book.fill"
        case .salary: "banknote"
        case .freelance: "laptopcomputer"
        case .investment: "chart.line.uptrend.xyaxis"
        case .gift: "gift.fill"
        case .other: "ellipsis.circle"
        }
    }

    var color: Color {
        switch self {
        case .food: .orange
        case .transport: .blue
        case .entertainment: .purple
        case .bills: .red
        case .shopping: .pink
        case .health: .green
        case .education: .indigo
        case .salary: .mint
        case .freelance: .teal
        case .investment: .cyan
        case .gift: .yellow
        case .other: .gray
        }
    }

    static var expenseCategories: [Category] {
        [.food, .transport, .entertainment, .bills, .shopping, .health, .education, .other]
    }

    static var incomeCategories: [Category] {
        [.salary, .freelance, .investment, .gift, .other]
    }
}
