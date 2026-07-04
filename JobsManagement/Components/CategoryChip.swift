import SwiftUI

struct CategoryChip: View {
    let category: Category
    var compact: Bool = false

    private var chipColor: Color {
        Color(hex: category.colorHex)
    }

    var body: some View {
        HStack(spacing: compact ? 4 : 6) {
            Image(systemName: category.iconName)
                .font(compact ? .caption2 : .caption)

            Text(category.name)
                .font(compact ? .caption2 : .caption)
                .lineLimit(1)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .foregroundStyle(chipColor)
        .background(chipColor.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    CategoryChip(
        category: Category(
            name: "Công việc",
            iconName: "briefcase.fill",
            colorHex: "#FF9500",
            categoryType: .work
        )
    )
    .padding()
}
