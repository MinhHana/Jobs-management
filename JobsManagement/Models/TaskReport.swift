import Foundation
import SwiftData

@Model
final class TaskReport {
    @Attribute(.unique) var id: UUID
    var reportedAt: Date
    var content: String
    var progressSnapshot: Int

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
