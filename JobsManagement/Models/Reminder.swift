import Foundation
import SwiftData

@Model
final class Reminder {
    @Attribute(.unique) var id: UUID
    var type: ReminderType
    var scheduledAt: Date
    var isEnabled: Bool

    var task: JobTask?

    init(
        id: UUID = UUID(),
        type: ReminderType,
        scheduledAt: Date,
        isEnabled: Bool = true,
        task: JobTask? = nil
    ) {
        self.id = id
        self.type = type
        self.scheduledAt = scheduledAt
        self.isEnabled = isEnabled
        self.task = task
    }
}
