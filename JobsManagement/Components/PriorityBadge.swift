import SwiftUI

struct PriorityBadge: View {
    let priority: Priority
    var compact: Bool = false

    var body: some View {
        Text(priority.displayName)
            .font(compact ? .caption2.bold() : .caption.bold())
            .padding(.horizontal, compact ? 6 : 8)
            .padding(.vertical, compact ? 2 : 4)
            .foregroundStyle(priority.color)
            .background(priority.color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    VStack {
        PriorityBadge(priority: .urgent)
        PriorityBadge(priority: .medium, compact: true)
    }
    .padding()
}
