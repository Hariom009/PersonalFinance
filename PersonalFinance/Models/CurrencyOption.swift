import Foundation

struct CurrencyOption: Identifiable, Hashable {
    let code: String
    let name: String
    let symbol: String

    var id: String { code }

    static let all: [CurrencyOption] = [
        CurrencyOption(code: "USD", name: "US Dollar", symbol: "$"),
        CurrencyOption(code: "EUR", name: "Euro", symbol: "€"),
        CurrencyOption(code: "GBP", name: "British Pound", symbol: "£"),
        CurrencyOption(code: "INR", name: "Indian Rupee", symbol: "₹"),
        CurrencyOption(code: "JPY", name: "Japanese Yen", symbol: "¥"),
        CurrencyOption(code: "CAD", name: "Canadian Dollar", symbol: "CA$"),
        CurrencyOption(code: "AUD", name: "Australian Dollar", symbol: "A$"),
        CurrencyOption(code: "CNY", name: "Chinese Yuan", symbol: "¥"),
        CurrencyOption(code: "CHF", name: "Swiss Franc", symbol: "CHF"),
        CurrencyOption(code: "KRW", name: "South Korean Won", symbol: "₩"),
        CurrencyOption(code: "SGD", name: "Singapore Dollar", symbol: "S$"),
        CurrencyOption(code: "HKD", name: "Hong Kong Dollar", symbol: "HK$"),
        CurrencyOption(code: "SEK", name: "Swedish Krona", symbol: "kr"),
        CurrencyOption(code: "NOK", name: "Norwegian Krone", symbol: "kr"),
        CurrencyOption(code: "NZD", name: "New Zealand Dollar", symbol: "NZ$"),
        CurrencyOption(code: "MXN", name: "Mexican Peso", symbol: "MX$"),
        CurrencyOption(code: "BRL", name: "Brazilian Real", symbol: "R$"),
        CurrencyOption(code: "ZAR", name: "South African Rand", symbol: "R"),
        CurrencyOption(code: "AED", name: "UAE Dirham", symbol: "د.إ"),
        CurrencyOption(code: "SAR", name: "Saudi Riyal", symbol: "﷼"),
        CurrencyOption(code: "THB", name: "Thai Baht", symbol: "฿"),
        CurrencyOption(code: "TWD", name: "New Taiwan Dollar", symbol: "NT$"),
        CurrencyOption(code: "PLN", name: "Polish Zloty", symbol: "zł"),
        CurrencyOption(code: "TRY", name: "Turkish Lira", symbol: "₺"),
        CurrencyOption(code: "RUB", name: "Russian Ruble", symbol: "₽"),
    ]

    static var defaultCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    static func option(for code: String) -> CurrencyOption? {
        all.first { $0.code == code }
    }
}
