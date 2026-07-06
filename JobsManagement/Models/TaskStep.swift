import Foundation
import SwiftData

@Model
final class TaskStep {
    var id: UUID = UUID()
    var title: String = ""
    var orderIndex: Int = 0
    var status: StepStatus = StepStatus.pending
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
