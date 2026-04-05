import Foundation

extension Double {
    private static var selectedCurrencyCode: String {
        UserDefaults.standard.string(forKey: "selectedCurrencyCode")
            ?? Locale.current.currency?.identifier
            ?? "USD"
    }

    var asCurrency: String {
        formatted(.currency(code: Self.selectedCurrencyCode))
    }

    var asCurrencyAbs: String {
        abs(self).formatted(.currency(code: Self.selectedCurrencyCode))
    }
}
