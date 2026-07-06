import Foundation

enum NotificationPreferences {
    static let notificationsEnabledKey = "notificationsEnabled"
    static let dueDateRemindersKey = "dueDateReminders"
    static let progressRemindersKey = "progressReminders"
    static let dailyDigestEnabledKey = "dailyDigestEnabled"

    static var notificationsEnabled: Bool {
        UserDefaults.standard.object(forKey: notificationsEnabledKey) as? Bool ?? true
    }

    static var dueDateRemindersEnabled: Bool {
        notificationsEnabled &&
        (UserDefaults.standard.object(forKey: dueDateRemindersKey) as? Bool ?? true)
    }

    static var progressRemindersEnabled: Bool {
        notificationsEnabled &&
        (UserDefaults.standard.object(forKey: progressRemindersKey) as? Bool ?? true)
    }

    static var dailyDigestEnabled: Bool {
        notificationsEnabled &&
        (UserDefaults.standard.object(forKey: dailyDigestEnabledKey) as? Bool ?? true)
    }
}
