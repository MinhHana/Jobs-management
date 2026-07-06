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
        guard NotificationPreferences.dueDateRemindersEnabled,
              let dueDate = task.dueDate else { return }

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
        }
    }

    func scheduleProgressReminder(for task: JobTask, at fireDate: Date? = nil) async {
        guard NotificationPreferences.progressRemindersEnabled else { return }

        guard let scheduledDate = fireDate ?? Self.defaultProgressCheckDate(for: task),
              scheduledDate > .now else { return }

        let identifier = progressIdentifier(for: task)

        let content = UNMutableNotificationContent()
        content.title = "Kiểm tra tiến độ"
        content.body = "Hãy cập nhật tiến độ cho \"\(task.title)\"."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: scheduledDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await center.add(request)
    }

    func scheduleCustomReminder(for task: JobTask, at date: Date) async {
        guard NotificationPreferences.notificationsEnabled,
              date > .now else { return }

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
        guard NotificationPreferences.dailyDigestEnabled else { return }

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

    // MARK: - Helpers

    /// Thời điểm nhắc kiểm tra tiến độ — giữa lúc bắt đầu và hạn hoàn thành.
    static func defaultProgressCheckDate(for task: JobTask, referenceDate: Date = .now) -> Date? {
        guard let dueDate = task.dueDate else {
            return referenceDate.addingTimeInterval(24 * 60 * 60)
        }

        let startDate: Date
        if let duration = task.estimatedDuration, duration > 0 {
            startDate = dueDate.addingTimeInterval(-duration)
        } else {
            startDate = referenceDate
        }

        let midpoint = startDate.addingTimeInterval(dueDate.timeIntervalSince(startDate) / 2)
        if midpoint > referenceDate {
            return midpoint
        }

        let oneHourLater = referenceDate.addingTimeInterval(60 * 60)
        return oneHourLater < dueDate ? oneHourLater : nil
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
