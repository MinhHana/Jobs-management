# Jobs Management

Ứng dụng quản lý công việc native trên iPhone — SwiftUI + SwiftData.

## Tính năng

- **Phân loại**: Cá nhân, Công việc, Dự định, Học tập, Sức khỏe, Tài chính, Nhà cửa (+ tùy chỉnh)
- **Công việc**: định kỳ / đột xuất / một lần, ưu tiên 4 mức, deadline
- **Bước thực hiện**: danh sách dọc, 3 trạng thái (Chưa làm → Đang làm → Hoàn thành), kéo thả sắp xếp
- **Báo cáo tiến độ**: timeline ghi chú theo thời gian
- **Dashboard**: thống kê, biểu đồ donut theo loại, bar chart 7 ngày
- **Thông báo**: nhắc hạn (1 ngày / 1 giờ trước), nhắc tiến độ, tổng kết buổi sáng 8:00

## Yêu cầu

- Xcode 15+
- iOS 17+
- macOS để build và chạy trên simulator/thiết bị
- Tài khoản Apple Developer với **iCloud** và **CloudKit** đã bật cho bundle ID `com.jobsmanagement.app`

## Cách chạy

1. Mở `JobsManagement/JobsManagement.xcodeproj` trong Xcode
2. Chọn target **JobsManagement**
3. Chọn simulator iPhone (VD: iPhone 15 Pro)
4. Nhấn **Run** (⌘R)

## Cấu trúc dự án

```
JobsManagement/
├── JobsManagementApp.swift      # Entry point
├── Models/                      # SwiftData models
├── Views/                       # Màn hình SwiftUI
├── Components/                  # UI components tái sử dụng
├── Services/                    # Notification, Progress, Seeder
├── Extensions/                  # Color, LocalizedLabels
└── Assets.xcassets/

docs/
├── design-spec.md               # Đối chiếu Figma ↔ code
├── figma-design-guide.md        # Spec chi tiết để dựng Figma
└── data-model.md                # Mô hình dữ liệu
```

## Tài liệu thiết kế

- [Design Spec](docs/design-spec.md) — tokens, components, screens
- [Figma Design Guide](docs/figma-design-guide.md) — layout pixel-level cho 8 frames Figma
- [Data Model](docs/data-model.md) — entities và quan hệ
- [iCloud Sync](docs/icloud-sync.md) — cấu hình đồng bộ CloudKit

## iCloud Sync

Dữ liệu SwiftData tự động đồng bộ qua **CloudKit** (container: `iCloud.com.jobsmanagement.app`).

### Cấu hình Xcode (bắt buộc trước khi chạy trên thiết bị)

1. Mở project → target **JobsManagement** → **Signing & Capabilities**
2. Thêm capability **iCloud** → tick **CloudKit**
3. Chọn container `iCloud.com.jobsmanagement.app` (tạo mới nếu chưa có)
4. Đảm bảo **Background Modes** → **Remote notifications** đã bật (đã cấu hình trong `Info.plist`)

### Trạng thái đồng bộ

Vào tab **Cài đặt** → mục **iCloud** để xem trạng thái tài khoản và sự kiện đồng bộ gần nhất.

## Ghi chú

- UI tiếng Việt
- Dữ liệu đồng bộ qua iCloud giữa các thiết bị cùng Apple ID
- Thông báo nhắc hẹn vẫn local trên từng thiết bị (không sync qua iCloud)
