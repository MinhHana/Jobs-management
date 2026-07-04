import SwiftUI

extension Priority {
    var displayName: String {
        switch self {
        case .low: "Thấp"
        case .medium: "Trung bình"
        case .high: "Cao"
        case .urgent: "Khẩn cấp"
        }
    }

    var color: Color {
        switch self {
        case .low: .gray
        case .medium: .blue
        case .high: .orange
        case .urgent: .red
        }
    }
}

extension StepStatus {
    var displayName: String {
        switch self {
        case .pending: "Chưa làm"
        case .inProgress: "Đang làm"
        case .completed: "Hoàn thành"
        case .skipped: "Bỏ qua"
        }
    }

    var iconName: String {
        switch self {
        case .pending: "circle"
        case .inProgress: "circle.lefthalf.filled"
        case .completed: "checkmark.circle.fill"
        case .skipped: "forward.circle"
        }
    }

    var tintColor: Color {
        switch self {
        case .pending: .secondary
        case .inProgress: .orange
        case .completed: .green
        case .skipped: .gray
        }
    }

    /// Cycles through pending → inProgress → completed.
    var nextInTapCycle: StepStatus {
        switch self {
        case .pending: .inProgress
        case .inProgress: .completed
        case .completed, .skipped: .pending
        }
    }
}

extension TaskStatus {
    var displayName: String {
        switch self {
        case .pending: "Chờ xử lý"
        case .inProgress: "Đang thực hiện"
        case .completed: "Hoàn thành"
        case .cancelled: "Đã hủy"
        case .overdue: "Quá hạn"
        }
    }

    var color: Color {
        switch self {
        case .pending: .secondary
        case .inProgress: .blue
        case .completed: .green
        case .cancelled: .gray
        case .overdue: .red
        }
    }
}

extension WorkTaskType {
    var displayName: String {
        switch self {
        case .recurring: "Định kỳ"
        case .adhoc: "Đột xuất"
        case .oneoff: "Một lần"
        }
    }
}

extension ReminderType {
    var displayName: String {
        switch self {
        case .dueDate: "Hạn hoàn thành"
        case .progress: "Tiến độ"
        case .recurrence: "Lặp lại"
        case .custom: "Tùy chỉnh"
        }
    }
}

extension TaskCategoryType {
    var displayName: String {
        switch self {
        case .personal: "Cá nhân"
        case .work: "Công việc"
        case .plans: "Dự định"
        case .study: "Học tập"
        case .health: "Sức khỏe"
        case .finance: "Tài chính"
        case .home: "Nhà cửa"
        case .custom: "Tùy chỉnh"
        }
    }
}
