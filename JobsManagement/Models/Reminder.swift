import Foundation
import SwiftData

@Model
final class Reminder {
    var id: UUID = UUID()
    var type: ReminderType = ReminderType.custom
    var scheduledAt: Date = .now
    var isEnabled: Bool = true

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
