import Foundation

struct TaskStatusService {
    /// Cập nhật trạng thái quá hạn dựa trên `dueDate`.
    static func syncOverdueStatus(for tasks: [JobTask], referenceDate: Date = .now) {
        for task in tasks {
            syncOverdueStatus(for: task, referenceDate: referenceDate)
        }
    }

    static func syncOverdueStatus(for task: JobTask, referenceDate: Date = .now) {
        guard task.status != .completed, task.status != .cancelled else { return }

        if let dueDate = task.dueDate, referenceDate > dueDate {
            task.status = .overdue
            return
        }

        if task.status == .overdue {
            restoreActiveStatus(for: task)
        }
    }

    private static func restoreActiveStatus(for task: JobTask) {
        let steps = task.steps
        if steps.contains(where: { $0.status == .inProgress || $0.status == .completed }) {
            task.status = .inProgress
        } else {
            task.status = .pending
        }
    }
}
