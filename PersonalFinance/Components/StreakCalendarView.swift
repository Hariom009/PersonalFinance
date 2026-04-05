import SwiftUI

struct StreakCalendarView: View {
    let days: [DayStatus]

    @State private var selectedDay: DayStatus?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 8) {
            // Week day headers
            HStack(spacing: 8) {
                ForEach(weekdayLabels.indices, id: \.self) { i in
                    Text(weekdayLabels[i])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            ZStack {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        dayCircle(for: day)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if selectedDay?.date == day.date {
                                        selectedDay = nil
                                    } else {
                                        selectedDay = day
                                    }
                                }
                            }
                    }
                }

                // Day detail overlay
                if let day = selectedDay {
                    dayDetailOverlay(for: day)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Day Circle

    @ViewBuilder
    private func dayCircle(for day: DayStatus) -> some View {
        let dayNumber = Calendar.current.component(.day, from: day.date)

        ZStack {
            if day.isFuture {
                Circle()
                    .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
                    .frame(width: 32, height: 32)
            } else if day.isToday {
                Circle()
                    .fill(day.didSpend ? Color.expenseRed.opacity(0.7) : greenForStreak(day.consecutiveNoSpendDays))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    )
            } else {
                Circle()
                    .fill(day.didSpend ? Color.expenseRed.opacity(0.7) : greenForStreak(day.consecutiveNoSpendDays))
                    .frame(width: 32, height: 32)
            }

            Text("\(dayNumber)")
                .font(.caption)
                .foregroundStyle(day.isFuture ? Color.secondary : Color.white)
        }
        .accessibilityLabel(dayAccessibilityLabel(for: day))
    }

    // MARK: - Heat Map Intensity

    private func greenForStreak(_ consecutiveDays: Int) -> Color {
        let baseOpacity = 0.4
        let perDay = 0.06
        let opacity = min(baseOpacity + perDay * Double(consecutiveDays), 1.0)
        return Color.incomeGreen.opacity(opacity)
    }

    // MARK: - Day Detail Overlay

    private func dayDetailOverlay(for day: DayStatus) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(day.date, style: .date)
                .font(.caption.weight(.medium))

            if day.isFuture {
                Text("Upcoming")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if day.didSpend {
                Text("Spent")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.expenseRed)
            } else {
                Text("No spend")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.incomeGreen)

                if day.consecutiveNoSpendDays > 1 {
                    Text("\(day.consecutiveNoSpendDays)-day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDay = nil
            }
        }
    }

    // MARK: - Accessibility

    private func dayAccessibilityLabel(for day: DayStatus) -> String {
        let dayNumber = Calendar.current.component(.day, from: day.date)
        if day.isFuture { return "Day \(dayNumber), future" }
        if day.isToday { return "Day \(dayNumber), today, \(day.didSpend ? "spent" : "no spend")" }
        return "Day \(dayNumber), \(day.didSpend ? "spent" : "no spend")"
    }
}
