import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var subtitle: String? = nil
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.bold())

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeaderView(title: "This Week", subtitle: "Daily spending")
        SectionHeaderView(title: "Recent Transactions", buttonTitle: "See All") { }
    }
    .padding()
}
