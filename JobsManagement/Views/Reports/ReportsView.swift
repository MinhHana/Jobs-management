import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query private var tasks: [JobTask]
    @Query private var reports: [TaskReport]

    private var completedCount: Int {
        tasks.filter { $0.status == .completed }.count
    }

    private var inProgressCount: Int {
        tasks.filter { $0.status == .inProgress }.count
    }

    private var completionRate: Int {
        guard !tasks.isEmpty else { return 0 }
        return Int((Double(completedCount) / Double(tasks.count)) * 100)
    }

    private var recentReports: [TaskReport] {
        Array(reports.sorted { $0.reportedAt > $1.reportedAt }.prefix(10))
    }

    private var weeklyData: [WeeklyCompletionItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let count = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= date && completedAt < nextDate
            }.count
            return WeeklyCompletionItem(
                date: date,
                label: date.formatted(.dateTime.weekday(.abbreviated)),
                count: count
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    completionStatsSection
                    weeklyChartSection
                    recentReportsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Báo cáo")
        }
    }

    private var completionStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thống kê hoàn thành")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Tỷ lệ hoàn thành",
                    value: "\(completionRate)%",
                    icon: "percent",
                    tint: .green
                )
                StatCard(
                    title: "Đã hoàn thành",
                    value: "\(completedCount)",
                    icon: "checkmark.circle.fill",
                    tint: .blue
                )
                StatCard(
                    title: "Đang thực hiện",
                    value: "\(inProgressCount)",
                    icon: "arrow.triangle.2.circlepath",
                    tint: .orange
                )
                StatCard(
                    title: "Báo cáo tiến độ",
                    value: "\(reports.count)",
                    icon: "doc.text.fill",
                    tint: .purple
                )
            }
        }
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hoàn thành trong tuần")
                .font(.headline)

            if weeklyData.allSatisfy({ $0.count == 0 }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 180)
                    .overlay {
                        Text("Chưa có dữ liệu tuần này")
                            .foregroundStyle(.secondary)
                    }
            } else {
                Chart(weeklyData) { item in
                    BarMark(
                        x: .value("Ngày", item.label),
                        y: .value("Số lượng", item.count)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Báo cáo gần đây")
                .font(.headline)

            if recentReports.isEmpty {
                Text("Chưa có báo cáo tiến độ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(recentReports, id: \.id) { report in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            if let taskTitle = report.task?.title {
                                Text(taskTitle)
                                    .font(.subheadline.bold())
                            }
                            Spacer()
                            Text("\(report.progressSnapshot)%")
                                .font(.caption.bold())
                                .foregroundStyle(Color.accentColor)
                        }

                        Text(report.content)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        Text(report.reportedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

private struct WeeklyCompletionItem: Identifiable {
    let date: Date
    let label: String
    let count: Int

    var id: Date { date }
}

#Preview {
    ReportsView()
        .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
