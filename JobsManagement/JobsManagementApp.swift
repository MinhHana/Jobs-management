import SwiftUI
import SwiftData

@main
struct JobsManagementApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JobTask.self,
            TaskStep.self,
            TaskReport.self,
            Reminder.self,
            Category.self,
        ])

        do {
            let cloudConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private(CloudSyncConstants.containerIdentifier)
            )
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            fatalError("Could not create ModelContainer with iCloud: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [JobTask]

    var body: some View {
        MainTabView()
            .onAppear {
                _ = try? CategorySeeder.seedDefaults(in: modelContext)
                TaskStatusService.syncOverdueStatus(for: tasks)
                Task {
                    await NotificationService.shared.requestAuthorization()
                    await CloudSyncService.shared.refreshAccountStatus()
                    if NotificationPreferences.dailyDigestEnabled {
                        await NotificationService.shared.scheduleDailyDigest(at: 8)
                    }
                }
            }
    }
}
