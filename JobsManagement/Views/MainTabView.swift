import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddTask = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Tổng quan", systemImage: "chart.pie.fill")
                }
                .tag(0)

            TaskListView()
                .tabItem {
                    Label("Công việc", systemImage: "checklist")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Label("Thêm mới", systemImage: "plus.circle.fill")
                }
                .tag(2)

            ReportsView()
                .tabItem {
                    Label("Báo cáo", systemImage: "chart.bar.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Cài đặt", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 2 {
                showAddTask = true
                selectedTab = 1
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
