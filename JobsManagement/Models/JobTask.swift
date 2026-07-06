import Foundation
import SwiftData

@Model
final class JobTask {
    var title: String = ""
    var notes: String = ""
    var workTaskType: WorkTaskType = .oneoff
    var priority: Priority = .medium
    var dueDate: Date?
    var completedAt: Date?
    var status: TaskStatus = .pending
    var progressPercent: Int = 0
    var recurrenceRule: String?
    var estimatedDuration: TimeInterval?

    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \TaskStep.task)
    var steps: [TaskStep]?

    @Relationship(deleteRule: .cascade, inverse: \TaskReport.task)
    var reports: [TaskReport]?

    @Relationship(deleteRule: .cascade, inverse: \Reminder.task)
    var reminders: [Reminder]?

    init(
        title: String,
        notes: String = "",
        workTaskType: WorkTaskType = .oneoff,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        completedAt: Date? = nil,
        status: TaskStatus = .pending,
        progressPercent: Int = 0,
        recurrenceRule: String? = nil,
        estimatedDuration: TimeInterval? = nil,
        category: Category? = nil
    ) {
        self.title = title
        self.notes = notes
        self.workTaskType = workTaskType
        self.priority = priority
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.status = status
        self.progressPercent = progressPercent
        self.recurrenceRule = recurrenceRule
        self.estimatedDuration = estimatedDuration
        self.category = category
    }

    func appendStep(_ step: TaskStep) {
        if steps == nil { steps = [] }
        steps?.append(step)
    }

    func appendReport(_ report: TaskReport) {
        if reports == nil { reports = [] }
        reports?.append(report)
    }

    func appendReminder(_ reminder: Reminder) {
        if reminders == nil { reminders = [] }
        reminders?.append(reminder)
    }

    func clearReminders() {
        reminders = []
    }
}
