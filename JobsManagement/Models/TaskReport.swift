import Foundation
import SwiftData

@Model
final class TaskReport {
    var id: UUID = UUID()
    var reportedAt: Date = .now
    var content: String = ""
    var progressSnapshot: Int = 0

    var task: JobTask?

    init(
        id: UUID = UUID(),
        reportedAt: Date = .now,
        content: String,
        progressSnapshot: Int,
        task: JobTask? = nil
    ) {
        self.id = id
        self.reportedAt = reportedAt
        self.content = content
        self.progressSnapshot = progressSnapshot
        self.task = task
    }
}
