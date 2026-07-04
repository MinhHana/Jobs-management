import SwiftUI
import SwiftData

struct StepRow: View {
    @Bindable var step: TaskStep
    var showDragHandle: Bool = false
    var onStatusChanged: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            if showDragHandle {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }

            Button {
                cycleStatus()
            } label: {
                Image(systemName: step.status.iconName)
                    .font(.title3)
                    .foregroundStyle(step.status.tintColor)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.body)
                    .strikethrough(step.status == .completed, color: .secondary)
                    .foregroundStyle(step.status == .completed ? .secondary : .primary)

                Text(step.status.displayName)
                    .font(.caption2)
                    .foregroundStyle(step.status.tintColor)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func cycleStatus() {
        step.status = step.status.nextInTapCycle
        step.completedAt = step.status == .completed ? .now : nil

        if let task = step.task {
            ProgressCalculator.syncProgress(for: task)
            updateTaskStatus(task)
        }

        onStatusChanged?()
    }

    private func updateTaskStatus(_ task: JobTask) {
        let steps = task.steps
        guard !steps.isEmpty else { return }

        if steps.allSatisfy({ $0.status == .completed || $0.status == .skipped }) {
            task.status = .completed
            task.completedAt = .now
        } else if steps.contains(where: { $0.status == .inProgress || $0.status == .completed }) {
            task.status = .inProgress
            task.completedAt = nil
        } else {
            task.status = .pending
            task.completedAt = nil
        }
    }
}

#Preview {
    let step = TaskStep(title: "Thu thập dữ liệu", orderIndex: 0, status: .inProgress)
    return StepRow(step: step)
        .padding()
}
