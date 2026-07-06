import SwiftUI
import SwiftData

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "Hệ thống"
        case .light: "Sáng"
        case .dark: "Tối"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dueDateReminders") private var dueDateReminders = true
    @AppStorage("progressReminders") private var progressReminders = true
    @AppStorage("dailyDigestEnabled") private var dailyDigestEnabled = true
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    @Query(sort: \Category.name) private var categories: [Category]

    private var cloudSync: CloudSyncService { CloudSyncService.shared }

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            Form {
                iCloudSection
                categoriesSection
                notificationsSection
                appearanceSection
                aboutSection
            }
            .navigationTitle("Cài đặt")
            .preferredColorScheme(appearanceMode.colorScheme)
            .onChange(of: notificationsEnabled) { _, enabled in
                Task {
                    if enabled && dailyDigestEnabled {
                        await NotificationService.shared.scheduleDailyDigest(at: 8)
                    } else {
                        await NotificationService.shared.cancelDailyDigest()
                    }
                }
            }
            .onChange(of: dailyDigestEnabled) { _, enabled in
                Task {
                    if enabled && notificationsEnabled {
                        await NotificationService.shared.scheduleDailyDigest(at: 8)
                    } else {
                        await NotificationService.shared.cancelDailyDigest()
                    }
                }
            }
            .onAppear {
                if dailyDigestEnabled && notificationsEnabled {
                    Task {
                        await NotificationService.shared.scheduleDailyDigest(at: 8)
                    }
                }
                Task {
                    await cloudSync.refreshAccountStatus()
                }
            }
        }
    }

    private var iCloudSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: iCloudIcon)
                    .font(.title2)
                    .foregroundStyle(iCloudColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Đồng bộ iCloud")
                        .font(.body)
                    Text(cloudSync.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let lastEvent = cloudSync.lastEventDescription {
                HStack {
                    Text("Lần đồng bộ gần nhất")
                    Spacer()
                    Text(lastEvent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            Button("Làm mới trạng thái") {
                Task {
                    await cloudSync.refreshAccountStatus()
                }
            }
        } header: {
            Text("iCloud")
        } footer: {
            Text("Công việc, bước thực hiện và báo cáo tiến độ tự động đồng bộ qua iCloud giữa iPhone, iPad và Mac của bạn.")
        }
    }

    private var iCloudIcon: String {
        switch cloudSync.accountStatus {
        case .available: "icloud.fill"
        case .noAccount: "icloud.slash"
        default: "icloud"
        }
    }

    private var iCloudColor: Color {
        switch cloudSync.accountStatus {
        case .available: .blue
        case .noAccount: .orange
        default: .secondary
        }
    }

    private var categoriesSection: some View {
        Section {
            ForEach(categories, id: \.id) { category in
                HStack(spacing: 12) {
                    Image(systemName: category.iconName)
                        .foregroundStyle(Color(hex: category.colorHex))
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.body)
                        Text(category.categoryType.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if category.isCustom {
                        Text("Tùy chỉnh")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("Danh mục")
        } footer: {
            Text("\(categories.count) danh mục")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Bật thông báo", isOn: $notificationsEnabled)

            if notificationsEnabled {
                Toggle("Nhắc hạn hoàn thành", isOn: $dueDateReminders)
                Toggle("Nhắc tiến độ", isOn: $progressReminders)
                Toggle("Tổng kết buổi sáng (8:00)", isOn: $dailyDigestEnabled)
            }
        } header: {
            Text("Thông báo")
        } footer: {
            Text("Tắt một loại nhắc nhở sẽ ngăn không lên lịch thông báo mới cho loại đó.")
        }
    }

    private var appearanceSection: some View {
        Section("Giao diện") {
            Picker("Chế độ hiển thị", selection: $appearanceModeRaw) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.displayName).tag(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var aboutSection: some View {
        Section("Thông tin") {
            HStack {
                Text("Phiên bản")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Category.self], inMemory: true)
}
