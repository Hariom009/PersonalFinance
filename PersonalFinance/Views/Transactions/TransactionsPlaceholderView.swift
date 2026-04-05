import SwiftUI

struct TransactionsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 60))
                    .foregroundStyle(.appPrimary)
                Text("Transactions")
                    .font(.title2.bold())
                Text("Track your income and expenses here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
         //   .navigationTitle("Transactions")
        }
    }
}

#Preview {
    TransactionsPlaceholderView()
}
