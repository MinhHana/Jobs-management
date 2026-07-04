import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var tasks: [JobTask]

    private var activeTasks: [JobTask] {
        tasks.filter { $0.status == .pending || $0.status == .inProgress || $0.status == .overdue }
    }

    private var completedTasks: [JobTask] {
        tasks.filter { $0.status == .completed }
    }

    private var overdueTasks: [JobTask] {
        tasks.filter { $0.status == .overdue }
    }

    private var priorityTasks: [JobTask] {
        tasks
            .filter { $0.status != .completed && $0.status != .cancelled }
            .sorted { lhs, rhs in
                if lhs.priority.sortOrder != rhs.priority.sortOrder {
                    return lhs.priority.sortOrder > rhs.priority.sortOrder
                }
                return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
            }
            .prefix(5)
            .map { $0 }
    }

    private var categoryChartData: [CategoryChartItem] {
        var counts: [String: (name: String, color: Color, count: Int)] = [:]
        for task in tasks {
            let name = task.category?.name ?? "Khác"
            let hex = task.category?.colorHex ?? "#8E8E93"
            let key = task.category?.id.uuidString ?? "other"
            let existing = counts[key]
            counts[key] = (name: name, color: Color(hex: hex), count: (existing?.count ?? 0) + 1)
        }
        return counts.map { CategoryChartItem(id: $0.key, name: $0.value.name, color: $0.value.color, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var weeklyProgressData: [WeeklyProgressItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let completed = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= date && completedAt < nextDate
            }.count
            return WeeklyProgressItem(
                date: date,
                label: date.formatted(.dateTime.weekday(.abbreviated)),
                count: completed
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsSection
                    categoryChartSection
                    weeklyProgressSection
                    prioritySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tổng quan")
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Đang làm",
                value: "\(activeTasks.count)",
                icon: "arrow.triangle.2.circlepath",
                tint: .blue
            )
            StatCard(
                title: "Hoàn thành",
                value: "\(completedTasks.count)",
                icon: "checkmark.circle.fill",
                tint: .green
            )
            StatCard(
                title: "Quá hạn",
                value: "\(overdueTasks.count)",
                icon: "exclamationmark.triangle.fill",
                tint: .red
            )
            StatCard(
                title: "Tổng cộng",
                value: "\(tasks.count)",
                icon: "tray.full.fill",
                tint: .purple
            )
        }
    }

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phân bổ theo loại")
                .font(.headline)

            if categoryChartData.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 200)
                    .overlay {
                        Text("Chưa có dữ liệu")
                            .foregroundStyle(.secondary)
                    }
            } else {
                Chart(categoryChartData) { item in
                    SectorMark(
                        angle: .value("Số lượng", item.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.color)
                    .annotation(position: .overlay) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center, spacing: 8)

                HStack(spacing: 12) {
                    ForEach(categoryChartData) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            Text(item.name)
                                .font(.caption2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tiến độ 7 ngày")
                .font(.headline)

            if weeklyProgressData.allSatisfy({ $0.count == 0 }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(height: 160)
                    .overlay {
                        Text("Chưa có hoàn thành trong tuần")
                            .foregroundStyle(.secondary)
                    }
            } else {
                Chart(weeklyProgressData) { item in
                    BarMark(
                        x: .value("Ngày", item.label),
                        y: .value("Hoàn thành", item.count)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 160)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ưu tiên cao")
                .font(.headline)

            if priorityTasks.isEmpty {
                Text("Không có công việc ưu tiên")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(priorityTasks, id: \.persistentModelID) { task in
                    NavigationLink {
                        TaskDetailView(task: task)
                    } label: {
                        TaskCard(task: task)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CategoryChartItem: Identifiable {
    let id: String
    let name: String
    let color: Color
    let count: Int
}

private struct WeeklyProgressItem: Identifiable {
    let date: Date
    let label: String
    let count: Int

    var id: Date { date }
}

private extension Priority {
    var sortOrder: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .urgent: 3
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
