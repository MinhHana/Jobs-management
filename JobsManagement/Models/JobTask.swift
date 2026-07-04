import Foundation
import SwiftData

@Model
final class JobTask {
    var title: String
    var notes: String
    var workTaskType: WorkTaskType
    var priority: Priority
    var dueDate: Date?
    var completedAt: Date?
    var status: TaskStatus
    var progressPercent: Int
    var recurrenceRule: String?
    var estimatedDuration: TimeInterval?

    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \TaskStep.task)
    var steps: [TaskStep] = []

    @Relationship(deleteRule: .cascade, inverse: \TaskReport.task)
    var reports: [TaskReport] = []

    @Relationship(deleteRule: .cascade, inverse: \Reminder.task)
    var reminders: [Reminder] = []

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
}
