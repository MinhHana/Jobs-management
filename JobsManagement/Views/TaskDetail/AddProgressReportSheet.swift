import SwiftUI
import SwiftData

struct AddProgressReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var task: JobTask

    @State private var content = ""
    @State private var reportedAt = Date.now

    var body: some View {
        NavigationStack {
            Form {
                Section("Thời gian") {
                    DatePicker("Ngày báo cáo", selection: $reportedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Nội dung") {
                    TextField("Mô tả tiến độ...", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Tiến độ hiện tại") {
                    HStack {
                        Text("Hoàn thành")
                        Spacer()
                        Text("\(task.progressPercent)%")
                            .foregroundStyle(.secondary)
                    }
                    ProgressBarView(progress: task.progressPercent, showLabel: false)
                }
            }
            .navigationTitle("Báo cáo tiến độ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { saveReport() }
                        .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveReport() {
        let trimmed = content.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let report = TaskReport(
            reportedAt: reportedAt,
            content: trimmed,
            progressSnapshot: task.progressPercent,
            task: task
        )
        modelContext.insert(report)
        task.reports.append(report)
        dismiss()
    }
}

#Preview {
    AddProgressReportSheet(
        task: JobTask(title: "Thử nghiệm", progressPercent: 40)
    )
    .modelContainer(for: [JobTask.self, TaskReport.self], inMemory: true)
}
