import CloudKit
import CoreData
import Foundation
import Observation

@Observable
final class CloudSyncService {
    static let shared = CloudSyncService()

    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    private(set) var statusMessage: String = "Đang kiểm tra iCloud..."
    private(set) var lastEventDescription: String?

    private init() {
        observeCloudKitEvents()
    }

    func refreshAccountStatus() async {
        let container = CKContainer(identifier: CloudSyncConstants.containerIdentifier)

        do {
            accountStatus = try await container.accountStatus()
            statusMessage = message(for: accountStatus)
        } catch {
            accountStatus = .couldNotDetermine
            statusMessage = "Không thể kiểm tra iCloud: \(error.localizedDescription)"
        }
    }

    private func message(for status: CKAccountStatus) -> String {
        switch status {
        case .available:
            "Đã đăng nhập iCloud. Dữ liệu tự động đồng bộ giữa các thiết bị."
        case .noAccount:
            "Chưa đăng nhập iCloud. Vào Cài đặt hệ thống để bật iCloud."
        case .restricted:
            "iCloud bị hạn chế trên thiết bị này."
        case .couldNotDetermine:
            "Không xác định được trạng thái iCloud."
        case .temporarilyUnavailable:
            "iCloud tạm thời không khả dụng. Thử lại sau."
        @unknown default:
            "Trạng thái iCloud không xác định."
        }
    }

    private func observeCloudKitEvents() {
        NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event else {
                return
            }
            self?.handle(event: event)
        }
    }

    private func handle(event: NSPersistentCloudKitContainer.Event) {
        if let error = event.error {
            lastEventDescription = "Lỗi đồng bộ: \(error.localizedDescription)"
            return
        }

        switch event.type {
        case .setup:
            lastEventDescription = "Đang thiết lập iCloud..."
        case .import:
            lastEventDescription = "Đã nhận dữ liệu từ iCloud"
        case .export:
            lastEventDescription = "Đã gửi dữ liệu lên iCloud"
        @unknown default:
            lastEventDescription = "Đang đồng bộ..."
        }
    }
}
