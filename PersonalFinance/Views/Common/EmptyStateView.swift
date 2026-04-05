import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3.bold())

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.95)
        .animation(.easeOut(duration: 0.4), value: hasAppeared)
        .onAppear { hasAppeared = true }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        iconName: "list.bullet.rectangle",
        title: "No Transactions Yet",
        subtitle: "Start tracking your income and expenses to see them here.",
        actionTitle: "Add Transaction"
    ) { }
}
