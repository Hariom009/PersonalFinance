import Foundation

extension Double {
    var asCurrency: String {
        let code = Locale.current.currency?.identifier ?? "USD"
        return formatted(.currency(code: code))
    }

    var asCurrencyAbs: String {
        let code = Locale.current.currency?.identifier ?? "USD"
        return abs(self).formatted(.currency(code: code))
    }
}
