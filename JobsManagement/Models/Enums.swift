import Foundation

enum TaskCategoryType: String, Codable, CaseIterable, Sendable {
    case personal
    case work
    case plans
    case study
    case health
    case finance
    case home
    case custom
}

enum WorkTaskType: String, Codable, CaseIterable, Sendable {
    case recurring
    case adhoc
    case oneoff
}

enum Priority: String, Codable, CaseIterable, Sendable {
    case low
    case medium
    case high
    case urgent
}

enum TaskStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case inProgress
    case completed
    case cancelled
    case overdue
}

enum StepStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case inProgress
    case completed
    case skipped
}

enum ReminderType: String, Codable, CaseIterable, Sendable {
    case dueDate
    case progress
    case recurrence
    case custom
}
