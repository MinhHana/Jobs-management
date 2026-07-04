# Mô hình dữ liệu — Jobs Management

Ứng dụng sử dụng **SwiftData** (iOS 17+) với **iCloud sync** qua CloudKit.

## Đồng bộ iCloud

| Thành phần | Chi tiết |
|---|---|
| Container | `iCloud.com.jobsmanagement.app` |
| Cơ chế | SwiftData `ModelConfiguration(cloudKitDatabase: .private(...))` |
| Phạm vi sync | JobTask, TaskStep, TaskReport, Reminder, Category |
| Không sync | Thông báo local (`UserNotifications`) — mỗi thiết bị tự schedule |

Entitlements: `JobsManagement.entitlements` — CloudKit + iCloud container.

Danh mục mặc định dùng **UUID cố định** theo `categoryType` để tránh trùng khi nhiều thiết bị seed đồng thời.

## Sơ đồ quan hệ

```
Category 1──* JobTask 1──* TaskStep
                    1──* TaskReport
                    1──* Reminder
```

## Entities

### Category

| Thuộc tính | Kiểu | Mô tả |
|---|---|---|
| `id` | UUID | Khóa duy nhất |
| `name` | String | Tên hiển thị (VD: Cá nhân, Công việc) |
| `iconName` | String | SF Symbol |
| `colorHex` | String | Màu hex (#RRGGBB) |
| `categoryType` | TaskCategoryType | Loại enum |
| `isCustom` | Bool | Danh mục do người dùng tạo |

**Danh mục mặc định:** Cá nhân, Công việc, Dự định, Học tập, Sức khỏe, Tài chính, Nhà cửa — seed bởi `CategorySeeder`.

### JobTask

| Thuộc tính | Kiểu | Mô tả |
|---|---|---|
| `title` | String | Tiêu đề |
| `notes` | String | Ghi chú |
| `workTaskType` | WorkTaskType | `recurring` / `adhoc` / `oneoff` |
| `priority` | Priority | `low` / `medium` / `high` / `urgent` |
| `dueDate` | Date? | Hạn hoàn thành |
| `completedAt` | Date? | Thời điểm hoàn thành |
| `status` | TaskStatus | `pending` / `inProgress` / `completed` / `cancelled` / `overdue` |
| `progressPercent` | Int | 0–100, tự tính từ bước |
| `recurrenceRule` | String? | `daily` / `weekly` / `monthly` |
| `estimatedDuration` | TimeInterval? | Thời gian ước tính (giây) |
| `category` | Category? | Danh mục |

### TaskStep

| Thuộc tính | Kiểu | Mô tả |
|---|---|---|
| `id` | UUID | Khóa duy nhất |
| `title` | String | Tên bước |
| `orderIndex` | Int | Thứ tự (0 = trên cùng) |
| `status` | StepStatus | `pending` / `inProgress` / `completed` / `skipped` |
| `completedAt` | Date? | Thời điểm hoàn thành bước |
| `task` | JobTask? | Công việc cha |

**Chu kỳ trạng thái khi tap:** Chưa làm → Đang làm → Hoàn thành → Chưa làm

### TaskReport

| Thuộc tính | Kiểu | Mô tả |
|---|---|---|
| `id` | UUID | Khóa duy nhất |
| `reportedAt` | Date | Thời điểm báo cáo |
| `content` | String | Nội dung báo cáo |
| `progressSnapshot` | Int | % tiến độ tại thời điểm báo cáo |
| `task` | JobTask? | Công việc liên quan |

### Reminder

| Thuộc tính | Kiểu | Mô tả |
|---|---|---|
| `id` | UUID | Khóa duy nhất |
| `type` | ReminderType | `dueDate` / `progress` / `recurrence` / `custom` |
| `scheduledAt` | Date | Thời gian nhắc |
| `isEnabled` | Bool | Bật/tắt |
| `task` | JobTask? | Công việc liên quan |

## Enums

### TaskCategoryType
`personal`, `work`, `plans`, `study`, `health`, `finance`, `home`, `custom`

### WorkTaskType
- `recurring` — Định kỳ (lặp theo chu kỳ)
- `adhoc` — Đột xuất
- `oneoff` — Một lần

### Priority
`low` (Thấp) → `medium` (Trung bình) → `high` (Cao) → `urgent` (Khẩn cấp)

## Logic tiến độ

`ProgressCalculator`:
- `calculateProgress(from:)` — % bước hoàn thành
- `syncProgress(for:)` — cập nhật `progressPercent` trên JobTask
- `isBehindSchedule(task:)` — so sánh tiến độ thực tế vs kỳ vọng theo thời gian
- `shouldTriggerProgressReminder(task:)` — kích hoạt nhắc tiến độ

## Cascade delete

- Xóa `JobTask` → xóa `TaskStep`, `TaskReport`, `Reminder` con
- Xóa `Category` → `nullify` trên JobTask (giữ task, bỏ category)
