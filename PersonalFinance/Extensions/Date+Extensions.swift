import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .weekOfYear)
    }

    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .month)
    }

    var formattedShort: String {
        formatted(.dateTime.month(.abbreviated).day())
    }

    var formattedMedium: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }

    var formattedRelative: String {
        if isToday { return "Today" }
        if isYesterday { return "Yesterday" }
        return formattedShort
    }

    var formattedTime: String {
        formatted(.dateTime.hour().minute())
    }

    var formattedRelativeWithTime: String {
        if isToday { return formattedTime }
        if isYesterday { return "Yesterday" }
        return formattedShort
    }
}
