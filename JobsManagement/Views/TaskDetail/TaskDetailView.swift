import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: JobTask

    @State private var showAddReport = false
    @State private var showAddStep = false
    @State private var newStepTitle = ""

    private var sortedSteps: [TaskStep] {
        (task.steps ?? []).sorted { $0.orderIndex < $1.orderIndex }
    }

    private var sortedReports: [TaskReport] {
        (task.reports ?? []).sorted { $0.reportedAt > $1.reportedAt }
    }

    private var categoryColor: Color {
        if let hex = task.category?.colorHex {
            return Color(hex: hex)
        }
        return .accentColor
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                progressSection
                stepsSection
                reportsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddReport) {
            AddProgressReportSheet(task: task)
        }
        .alert("Thêm bước", isPresented: $showAddStep) {
            TextField("Tên bước", text: $newStepTitle)
            Button("Hủy", role: .cancel) {
                newStepTitle = ""
            }
            Button("Thêm") {
                addStep()
            }
            .disabled(newStepTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let category = task.category {
                    CategoryChip(category: category)
                }
                PriorityBadge(priority: task.priority)
                Spacer()
                Text(task.status.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(task.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(task.status.color.opacity(0.12))
                    .clipShape(Capsule())
            }

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(date: .long, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Label(task.workTaskType.displayName, systemImage: "repeat")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tiến độ")
                .font(.headline)

            ProgressBarView(progress: task.progressPercent, tint: categoryColor)

            if ProgressCalculator.isBehindSchedule(task: task) {
                Label("Đang chậm tiến độ so với kế hoạch", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Các bước")
                    .font(.headline)
                Spacer()
                Text("\(completedStepCount)/\((task.steps ?? []).count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if sortedSteps.isEmpty {
                Text("Chưa có bước nào")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                List {
                    ForEach(sortedSteps, id: \.id) { step in
                        StepRow(step: step, showDragHandle: true)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove(perform: moveSteps)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .frame(height: CGFloat(sortedSteps.count) * 52)
                .environment(\.editMode, .constant(.active))
            }

            Button {
                showAddStep = true
            } label: {
                Label("Thêm bước", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Báo cáo tiến độ")
                    .font(.headline)
                Spacer()
                Button {
                    showAddReport = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }

            if sortedReports.isEmpty {
                Text("Chưa có báo cáo nào")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                ForEach(sortedReports, id: \.id) { report in
                    ReportTimelineRow(report: report)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private var completedStepCount: Int {
        (task.steps ?? []).filter { $0.status == .completed }.count
    }

    private func addStep() {
        let title = newStepTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        let nextIndex = ((task.steps ?? []).map(\.orderIndex).max() ?? -1) + 1
        let step = TaskStep(title: title, orderIndex: nextIndex, task: task)
        modelContext.insert(step)
        task.appendStep(step)
        ProgressCalculator.syncProgress(for: task)
        newStepTitle = ""
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        var steps = sortedSteps
        steps.move(fromOffsets: source, toOffset: destination)
        for (index, step) in steps.enumerated() {
            step.orderIndex = index
        }
        ProgressCalculator.syncProgress(for: task)
    }
}

private struct ReportTimelineRow: View {
    let report: TaskReport

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(report.reportedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(report.progressSnapshot)%")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                }

                Text(report.content)
                    .font(.subheadline)
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: JobTask(title: "Dự án mẫu", notes: "Ghi chú thử nghiệm", priority: .high, status: .inProgress, progressPercent: 50)
        )
    }
    .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
