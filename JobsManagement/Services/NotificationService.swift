import Foundation
import SwiftData
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            // Authorization failures are non-fatal; reminders simply won't fire.
        }
    }

    // MARK: - Scheduling

    func scheduleDeadlineReminder(for task: JobTask) async {
        guard let dueDate = task.dueDate else { return }

        let offsets: [(TimeInterval, String)] = [
            (24 * 60 * 60, "1day"),
            (60 * 60, "1hour"),
        ]

        let now = Date.now

        for (offset, suffix) in offsets {
            let fireDate = dueDate.addingTimeInterval(-offset)
            guard fireDate > now else { continue }

            let identifier = deadlineIdentifier(for: task, suffix: suffix)
            let content = UNMutableNotificationContent()
            content.title = suffix == "1day" ? "Sắp đến hạn" : "Gần đến hạn"
            content.body = suffix == "1day"
                ? "Còn 1 ngày đến hạn: \(task.title)"
                : "Còn 1 giờ đến hạn: \(task.title)"
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            try? await center.add(request)

            let reminder = Reminder(type: .dueDate, scheduledAt: fireDate, task: task)
            task.reminders.append(reminder)
        }
    }

    func scheduleProgressReminder(for task: JobTask) async {
        guard ProgressCalculator.shouldTriggerProgressReminder(task: task) else { return }

        let fireDate = Date.now.addingTimeInterval(60 * 60)
        let identifier = progressIdentifier(for: task)

        let content = UNMutableNotificationContent()
        content.title = "Tiến độ chậm"
        content.body = "Công việc \"\(task.title)\" đang chậm so với kế hoạch. Hãy cập nhật tiến độ."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await center.add(request)

        let reminder = Reminder(type: .progress, scheduledAt: fireDate, task: task)
        task.reminders.append(reminder)
    }

    func scheduleCustomReminder(for task: JobTask, at date: Date) async {
        guard date > .now else { return }

        let identifier = "\(notificationPrefix(for: task))-custom"
        let content = UNMutableNotificationContent()
        content.title = "Nhắc nhở"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await center.add(request)
    }

    func scheduleDailyDigest(at hour: Int = 8) async {
        let identifier = dailyDigestIdentifier

        let content = UNMutableNotificationContent()
        content.title = "Tổng kết buổi sáng"
        content.body = "Xem các công việc cần làm hôm nay."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await center.add(request)
    }

    func cancelDailyDigest() async {
        center.removePendingNotificationRequests(withIdentifiers: [dailyDigestIdentifier])
    }

    // MARK: - Cancellation

    func cancelReminders(for task: JobTask) async {
        let prefix = notificationPrefix(for: task)
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(prefix) }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        task.reminders.removeAll()
    }

    // MARK: - Identifiers

    private var dailyDigestIdentifier: String { "daily-digest" }

    private func notificationPrefix(for task: JobTask) -> String {
        "task-\(task.persistentModelID)"
    }

    private func deadlineIdentifier(for task: JobTask, suffix: String) -> String {
        "\(notificationPrefix(for: task))-deadline-\(suffix)"
    }

    private func progressIdentifier(for task: JobTask) -> String {
        "\(notificationPrefix(for: task))-progress"
    }
}
