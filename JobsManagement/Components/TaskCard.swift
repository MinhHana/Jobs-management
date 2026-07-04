import SwiftUI

struct TaskCard: View {
    let task: JobTask

    private var categoryColor: Color {
        if let hex = task.category?.colorHex {
            return Color(hex: hex)
        }
        return .accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .lineLimit(2)

                    if let category = task.category {
                        CategoryChip(category: category, compact: true)
                    }
                }

                Spacer(minLength: 8)

                PriorityBadge(priority: task.priority)
            }

            ProgressBarView(progress: task.progressPercent, tint: categoryColor)

            HStack {
                Label(task.status.displayName, systemImage: statusIcon)
                    .font(.caption)
                    .foregroundStyle(task.status.color)

                Spacer()

                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusIcon: String {
        switch task.status {
        case .pending: "clock"
        case .inProgress: "arrow.triangle.2.circlepath"
        case .completed: "checkmark.circle"
        case .cancelled: "xmark.circle"
        case .overdue: "exclamationmark.triangle"
        }
    }
}

#Preview {
    let category = Category(
        name: "Công việc",
        iconName: "briefcase.fill",
        colorHex: "#FF9500",
        categoryType: .work
    )
    let task = JobTask(
        title: "Hoàn thành báo cáo tuần",
        priority: .high,
        dueDate: .now.addingTimeInterval(86400 * 3),
        status: .inProgress,
        progressPercent: 45,
        category: category
    )

    return TaskCard(task: task)
        .padding()
}
