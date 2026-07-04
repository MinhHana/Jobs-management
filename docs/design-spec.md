# Design Spec — Jobs Management

Tài liệu đối chiếu giữa thiết kế Figma và implementation SwiftUI. Chi tiết pixel-level xem thêm [figma-design-guide.md](figma-design-guide.md).

## Design principles

- **Apple HIG** + phong cách clean minimal (Things 3, Todoist, Apple Reminders)
- **Liquid Glass** cho tab bar và overlay khi phù hợp
- **Tiếng Việt** toàn bộ UI
- **Dark mode** semantic — không hardcode màu nền

## Design tokens

| Token | Giá trị |
|---|---|
| Font | SF Pro (system) |
| Grid | 4pt (8, 12, 16, 24, 32) |
| Card radius | 12pt |
| Sheet radius | 20pt |
| Pill radius | full (Capsule) |
| Background | `systemGroupedBackground` |
| Card | `secondarySystemGroupedBackground` |
| Primary | `accentColor` / system Blue |

### Màu ưu tiên

| Mức | Màu |
|---|---|
| Thấp | Gray |
| Trung bình | Blue |
| Cao | Orange |
| Khẩn cấp | Red |

### Màu trạng thái bước

| Trạng thái | Icon | Màu |
|---|---|---|
| Chưa làm | `circle` | Secondary |
| Đang làm | `circle.lefthalf.filled` | Orange |
| Hoàn thành | `checkmark.circle.fill` | Green |

## Component mapping

| Figma component | SwiftUI file | Ghi chú |
|---|---|---|
| TaskCard | `Components/TaskCard.swift` | Icon category, title, deadline, priority |
| StepRow | `Components/StepRow.swift` | 3-state tap cycle |
| StatCard | `Components/StatCard.swift` | Số lớn + label + icon |
| CategoryChip | `Components/CategoryChip.swift` | Pill với icon + màu |
| ProgressBar | `Components/ProgressBarView.swift` | Linear progress |
| EmptyState | `Components/EmptyStateView.swift` | Icon + title + message |
| PriorityBadge | `Components/PriorityBadge.swift` | Capsule màu theo mức |

## Screen specs

### 1. Dashboard (Tổng quan)

- **Stats grid** 2×2: Đang làm, Hoàn thành, Quá hạn, Tổng cộng
- **Donut chart**: phân bổ theo loại công việc (`DashboardView.categoryChartSection`)
- **Bar chart**: tiến độ 7 ngày (`DashboardView.weeklyProgressSection`)
- **Priority list**: top 5 việc ưu tiên cao → `TaskDetailView`

### 2. Task List (Công việc)

- Horizontal category filter chips
- Search bar
- Sort menu (hạn, ưu tiên, tên, tiến độ)
- Swipe: xóa (trailing), hoàn thành (trailing), bắt đầu/tạm dừng (leading)

### 3. Task Detail (Chi tiết)

- Header: category chip, priority badge, status, notes, deadline
- Progress bar + cảnh báo chậm tiến độ
- Vertical steps list (reorderable)
- Report timeline với nút thêm báo cáo

### 4. Add Task (Thêm mới)

- Wizard 2 bước: Thông tin → Bước & Nhắc nhở
- Recurrence toggle (chỉ loại Công việc)
- Lưu SwiftData + schedule notifications

### 5. Reports (Báo cáo)

- Completion rate stats
- Weekly bar chart
- Recent reports list (10 mục gần nhất)

### 6. Settings (Cài đặt)

- Danh mục list
- Notification toggles (hạn, tiến độ, tổng kết sáng)
- Appearance picker (Hệ thống / Sáng / Tối)

## Navigation

5-tab `TabView`:
1. Tổng quan — `chart.pie.fill`
2. Công việc — `checklist`
3. Thêm mới — `plus.circle.fill` (mở sheet)
4. Báo cáo — `chart.bar.fill`
5. Cài đặt — `gearshape.fill`

## Prototype flows

1. Dashboard → tap task → Detail → tap step → đổi trạng thái
2. Tab Công việc → + → Add Task wizard → Tạo → quay về list
3. Detail → + báo cáo → nhập nội dung → lưu timeline

## Accessibility

- Dynamic Type support (system fonts)
- VoiceOver labels trên StepRow và TaskCard
- Minimum tap target 44×44pt
- Semantic colors cho dark mode

## Figma file structure (khi tạo trên Figma)

```
Pages/
├── 🎨 Design System (tokens, components)
├── 📱 Screens (8 frames @ 393×852)
├── 🌙 Dark Mode
└── 🔗 Prototype
```

Xem [figma-design-guide.md](figma-design-guide.md) để dựng Figma từ spec này.
