import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    @Binding var selected: Category?

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories) { category in
                CategoryCell(
                    category: category,
                    isSelected: selected == category
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = category
                    }
                }
                .sensoryFeedback(.selection, trigger: selected)
            }
        }
    }
}

private struct CategoryCell: View {
    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(isSelected ? 1.0 : 0.05))
                    .frame(width: 48, height: 48)

                Image(systemName: category.iconName)
                    .font(.system(size: AppSize.iconMedium))
                    .foregroundStyle(isSelected ? .white : category.color)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)

            Text(category.title)
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}

#Preview {
    @Previewable @State var selected: Category? = .food
    CategoryGridView(categories: Category.expenseCategories, selected: $selected)
        .padding()
}
