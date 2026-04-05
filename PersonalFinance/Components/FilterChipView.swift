import SwiftUI

struct FilterChipView: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? Color.appPrimary : Color.cardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    HStack {
        FilterChipView(label: "All", isSelected: true) { }
        FilterChipView(label: "Income", isSelected: false) { }
        FilterChipView(label: "Expense", isSelected: false) { }
    }
    .padding()
}
