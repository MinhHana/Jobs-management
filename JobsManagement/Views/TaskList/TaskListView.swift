import SwiftUI
import SwiftData

enum TaskSortOption: String, CaseIterable, Identifiable {
    case dueDateAsc = "dueDateAsc"
    case dueDateDesc = "dueDateDesc"
    case priorityDesc = "priorityDesc"
    case titleAsc = "titleAsc"
    case progressDesc = "progressDesc"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dueDateAsc: "Hạn sớm nhất"
        case .dueDateDesc: "Hạn muộn nhất"
        case .priorityDesc: "Ưu tiên cao"
        case .titleAsc: "Tên A-Z"
        case .progressDesc: "Tiến độ cao"
        }
    }
}

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [JobTask]
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var searchText = ""
    @State private var selectedCategoryID: UUID?
    @State private var selectedWorkType: WorkTaskType?
    @State private var sortOption: TaskSortOption = .dueDateAsc
    @State private var showSortMenu = false

    private var filteredTasks: [JobTask] {
        var result = allTasks.filter { $0.status != .cancelled }

        if let selectedCategoryID {
            result = result.filter { $0.category?.id == selectedCategoryID }
        }

        if let selectedWorkType {
            result = result.filter { $0.workTaskType == selectedWorkType }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        return sorted(result)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredTasks.isEmpty && searchText.isEmpty && selectedCategoryID == nil && selectedWorkType == nil {
                    EmptyStateView(
                        icon: "checklist",
                        title: "Chưa có công việc",
                        message: "Thêm công việc mới để bắt đầu quản lý."
                    )
                } else if filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "Không tìm thấy",
                        message: "Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm."
                    )
                } else {
                    List {
                        ForEach(filteredTasks, id: \.persistentModelID) { task in
                            NavigationLink {
                                TaskDetailView(task: task)
                            } label: {
                                TaskCard(task: task)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteTask(task)
                                } label: {
                                    Label("Xóa", systemImage: "trash")
                                }

                                if task.status != .completed {
                                    Button {
                                        markCompleted(task)
                                    } label: {
                                        Label("Xong", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggleInProgress(task)
                                } label: {
                                    Label(
                                        task.status == .inProgress ? "Tạm dừng" : "Bắt đầu",
                                        systemImage: task.status == .inProgress ? "pause.fill" : "play.fill"
                                    )
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Công việc")
            .searchable(text: $searchText, prompt: "Tìm kiếm công việc")
            .onAppear {
                TaskStatusService.syncOverdueStatus(for: allTasks)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sắp xếp", selection: $sortOption) {
                            ForEach(TaskSortOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    categoryFilterBar
                    workTypeFilterBar
                }
            }
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Tất cả", isSelected: selectedCategoryID == nil) {
                    selectedCategoryID = nil
                }

                ForEach(categories, id: \.id) { category in
                    filterChip(
                        title: category.name,
                        isSelected: selectedCategoryID == category.id,
                        color: Color(hex: category.colorHex)
                    ) {
                        selectedCategoryID = category.id
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    private var workTypeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Mọi loại", isSelected: selectedWorkType == nil) {
                    selectedWorkType = nil
                }
                ForEach(WorkTaskType.allCases, id: \.self) { type in
                    filterChip(title: type.displayName, isSelected: selectedWorkType == type) {
                        selectedWorkType = type
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.bar)
    }

    private func filterChip(
        title: String,
        isSelected: Bool,
        color: Color = .accentColor,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : color)
                .background(isSelected ? color : color.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func sorted(_ tasks: [JobTask]) -> [JobTask] {
        switch sortOption {
        case .dueDateAsc:
            tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .dueDateDesc:
            tasks.sorted { ($0.dueDate ?? .distantPast) > ($1.dueDate ?? .distantPast) }
        case .priorityDesc:
            tasks.sorted { $0.priority.sortOrder > $1.priority.sortOrder }
        case .titleAsc:
            tasks.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .progressDesc:
            tasks.sorted { $0.progressPercent > $1.progressPercent }
        }
    }

    private func deleteTask(_ task: JobTask) {
        let prefix = NotificationService.shared.identifierPrefix(for: task)
        Task {
            await NotificationService.shared.cancelPendingNotifications(withPrefix: prefix)
        }
        modelContext.delete(task)
    }

    private func markCompleted(_ task: JobTask) {
        task.status = .completed
        task.completedAt = .now
        task.progressPercent = 100
        for step in (task.steps ?? []) where step.status != .completed {
            step.status = .completed
            step.completedAt = .now
        }
    }

    private func toggleInProgress(_ task: JobTask) {
        if task.status == .inProgress {
            task.status = .pending
        } else {
            task.status = .inProgress
        }
    }
}

private extension Priority {
    var sortOrder: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .urgent: 3
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
