import SwiftUI

struct CurrencyPickerView: View {
    @AppStorage("selectedCurrencyCode") private var selectedCode = CurrencyOption.defaultCode
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredCurrencies: [CurrencyOption] {
        if searchText.isEmpty { return CurrencyOption.all }
        let query = searchText.lowercased()
        return CurrencyOption.all.filter {
            $0.code.lowercased().contains(query)
            || $0.name.lowercased().contains(query)
            || $0.symbol.contains(query)
        }
    }

    var body: some View {
        List(filteredCurrencies) { currency in
            Button {
                selectedCode = currency.code
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(currency.name)
                            .foregroundStyle(.primary)
                        Text("\(currency.symbol) — \(currency.code)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if currency.code == selectedCode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .searchable(text: $searchText, prompt: "Search currencies")
        .navigationTitle("Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}
