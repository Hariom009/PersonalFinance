import Foundation

struct ExportService {
    static func generateCSV(transactions: [Transaction]) -> URL? {
        var csv = "Date,Type,Category,Amount,Note,Recurring\n"

        for t in transactions {
            let date = t.date.formattedMedium
            let type = t.type.rawValue
            let category = t.category.rawValue
            let amount = String(format: "%.2f", t.amount)
            let note = escapeCSVField(t.note)
            let recurring = t.isRecurring ? "Yes" : "No"

            csv += "\(date),\(type),\(category),\(amount),\(note),\(recurring)\n"
        }

        let fileName = "PersonalFinance_Export_\(Date.now.formatted(.dateTime.year().month().day())).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}
