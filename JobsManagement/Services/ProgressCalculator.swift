import Foundation

struct ProgressCalculator {
    /// Calculates progress as the percentage of resolved steps.
    ///
    /// A step counts as resolved when it is either completed or skipped, matching
    /// the completion rule used to auto-complete a task. This keeps a fully
    /// resolved (and therefore completed) task at 100%.
    static func calculateProgress(from steps: [TaskStep]) -> Int {
        guard !steps.isEmpty else { return 0 }

        let resolvedCount = steps.filter { $0.status == .completed || $0.status == .skipped }.count
        return Int((Double(resolvedCount) / Double(steps.count)) * 100)
    }

    /// Updates a task's `progressPercent` from its steps.
    static func syncProgress(for task: JobTask) {
        task.progressPercent = calculateProgress(from: task.steps ?? [])
    }

    /// Returns whether the task is behind its expected timeline.
    ///
    /// Expected progress is derived from elapsed time between the implicit start
    /// (`dueDate - estimatedDuration`) and `dueDate`. Tasks past due with
    /// incomplete progress are always considered behind schedule.
    static func isBehindSchedule(
        task: JobTask,
        referenceDate: Date = .now,
        tolerancePercent: Int = 10
    ) -> Bool {
        guard task.status != .completed,
              let dueDate = task.dueDate else {
            return false
        }

        if referenceDate >= dueDate {
            return task.progressPercent < 100
        }

        guard let duration = task.estimatedDuration, duration > 0 else {
            return false
        }

        let startDate = dueDate.addingTimeInterval(-duration)
        let totalInterval = dueDate.timeIntervalSince(startDate)
        guard totalInterval > 0 else { return false }

        let elapsed = referenceDate.timeIntervalSince(startDate)
        let expectedProgress = min(100, Int((elapsed / totalInterval) * 100))

        return task.progressPercent < expectedProgress - tolerancePercent
    }

    /// Whether a progress-type reminder should fire for this task.
    static func shouldTriggerProgressReminder(
        task: JobTask,
        referenceDate: Date = .now,
        tolerancePercent: Int = 10
    ) -> Bool {
        guard task.status == .inProgress || task.status == .pending else {
            return false
        }

        return isBehindSchedule(
            task: task,
            referenceDate: referenceDate,
            tolerancePercent: tolerancePercent
        )
    }
}
