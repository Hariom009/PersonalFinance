import SwiftUI

struct StreakCalendarView: View {
    let days: [DayStatus]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                dayCircle(for: day)
            }
        }
    }

    @ViewBuilder
    private func dayCircle(for day: DayStatus) -> some View {
        let dayNumber = Calendar.current.component(.day, from: day.date)

        ZStack {
            if day.isFuture {
                Circle()
                    .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
                    .frame(width: 28, height: 28)
            } else if day.isToday {
                Circle()
                    .fill(day.didSpend ? Color.expenseRed.opacity(0.7) : Color.incomeGreen)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    )
            } else {
                Circle()
                    .fill(day.didSpend ? Color.expenseRed.opacity(0.7) : Color.incomeGreen)
                    .frame(width: 28, height: 28)
            }

            Text("\(dayNumber)")
                .font(.caption2)
                .foregroundStyle(day.isFuture ? Color.secondary : Color.white)
        }
        .accessibilityLabel(dayAccessibilityLabel(for: day))
    }

    private func dayAccessibilityLabel(for day: DayStatus) -> String {
        let dayNumber = Calendar.current.component(.day, from: day.date)
        if day.isFuture { return "Day \(dayNumber), future" }
        if day.isToday { return "Day \(dayNumber), today, \(day.didSpend ? "spent" : "no spend")" }
        return "Day \(dayNumber), \(day.didSpend ? "spent" : "no spend")"
    }
}
