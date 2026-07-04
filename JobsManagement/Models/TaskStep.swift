import Foundation
import SwiftData

@Model
final class TaskStep {
    @Attribute(.unique) var id: UUID
    var title: String
    var orderIndex: Int
    var status: StepStatus
    var completedAt: Date?

    var task: JobTask?

    init(
        id: UUID = UUID(),
        title: String,
        orderIndex: Int,
        status: StepStatus = .pending,
        completedAt: Date? = nil,
        task: JobTask? = nil
    ) {
        self.id = id
        self.title = title
        self.orderIndex = orderIndex
        self.status = status
        self.completedAt = completedAt
        self.task = task
    }
}
