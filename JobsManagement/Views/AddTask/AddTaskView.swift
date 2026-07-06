import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var currentStep = 0

    // Step 1: Basic info
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedCategory: Category?
    @State private var priority: Priority = .medium
    @State private var workTaskType: WorkTaskType = .oneoff
    @State private var dueDate = Date.now.addingTimeInterval(86400 * 7)
    @State private var hasDueDate = true
    @State private var isRecurring = false
    @State private var recurrenceRule = "weekly"

    // Step 2: Steps & reminders
    @State private var stepTitles: [String] = [""]
    @State private var enableDueReminder = true
    @State private var enableProgressReminder = false
    @State private var customReminderDate = Date.now.addingTimeInterval(3600)
    @State private var customReminderEnabled = false

    private var isWorkCategory: Bool {
        selectedCategory?.categoryType == .work
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedCategory != nil
        default:
            true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator

                TabView(selection: $currentStep) {
                    basicInfoStep.tag(0)
                    stepsAndRemindersStep.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
            .navigationTitle("Thêm công việc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        if currentStep > 0 {
                            Button("Quay lại") {
                                withAnimation { currentStep -= 1 }
                            }
                        }
                        Spacer()
                        if currentStep < 1 {
                            Button("Tiếp theo") {
                                withAnimation { currentStep += 1 }
                            }
                            .disabled(!canProceed)
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Tạo công việc") {
                                createTask()
                            }
                            .disabled(!canProceed)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = categories.first
                }
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            stepDot(index: 0, label: "Thông tin")
            Rectangle()
                .fill(currentStep >= 1 ? Color.accentColor : Color(.systemGray4))
                .frame(height: 2)
            stepDot(index: 1, label: "Bước & Nhắc nhở")
        }
        .padding()
    }

    private func stepDot(index: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(currentStep >= index ? Color.accentColor : Color(.systemGray4))
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .foregroundStyle(currentStep >= index ? .primary : .secondary)
        }
    }

    // MARK: - Step 1

    private var basicInfoStep: some View {
        Form {
            Section("Thông tin cơ bản") {
                TextField("Tiêu đề", text: $title)
                TextField("Ghi chú", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Danh mục") {
                Picker("Danh mục", selection: $selectedCategory) {
                    ForEach(categories, id: \.id) { category in
                        HStack {
                            Image(systemName: category.iconName)
                            Text(category.name)
                        }
                        .tag(Optional(category))
                    }
                }
            }

            Section("Ưu tiên & Loại") {
                Picker("Ưu tiên", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { p in
                        Text(p.displayName).tag(p)
                    }
                }

                if isWorkCategory {
                    Picker("Loại công việc", selection: $workTaskType) {
                        ForEach(WorkTaskType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    Toggle("Lặp lại định kỳ", isOn: $isRecurring)
                        .onChange(of: isRecurring) { _, newValue in
                            workTaskType = newValue ? .recurring : .oneoff
                        }

                    if isRecurring {
                        Picker("Chu kỳ", selection: $recurrenceRule) {
                            Text("Hàng ngày").tag("daily")
                            Text("Hàng tuần").tag("weekly")
                            Text("Hàng tháng").tag("monthly")
                        }
                    }
                }
            }

            Section("Hạn hoàn thành") {
                Toggle("Đặt hạn", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Ngày hạn", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
        }
    }

    // MARK: - Step 2

    private var stepsAndRemindersStep: some View {
        Form {
            Section("Các bước thực hiện") {
                ForEach(stepTitles.indices, id: \.self) { index in
                    HStack {
                        TextField("Bước \(index + 1)", text: $stepTitles[index])
                        if stepTitles.count > 1 {
                            Button(role: .destructive) {
                                stepTitles.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    stepTitles.append("")
                } label: {
                    Label("Thêm bước", systemImage: "plus")
                }
            }

            Section("Nhắc nhở") {
                Toggle("Nhắc hạn hoàn thành", isOn: $enableDueReminder)
                Toggle("Nhắc tiến độ", isOn: $enableProgressReminder)

                Toggle("Nhắc tùy chỉnh", isOn: $customReminderEnabled)

                if customReminderEnabled {
                    DatePicker("Thời gian", selection: $customReminderDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
        }
    }

    // MARK: - Create

    private func createTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty, let category = selectedCategory else { return }

        let task = JobTask(
            title: trimmedTitle,
            notes: notes.trimmingCharacters(in: .whitespaces),
            workTaskType: isWorkCategory ? workTaskType : .oneoff,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            recurrenceRule: isRecurring ? recurrenceRule : nil,
            estimatedDuration: hasDueDate ? max(dueDate.timeIntervalSince(.now), 3600) : nil,
            category: category
        )
        modelContext.insert(task)

        let validSteps = stepTitles
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        for (index, stepTitle) in validSteps.enumerated() {
            let step = TaskStep(title: stepTitle, orderIndex: index, task: task)
            modelContext.insert(step)
            task.steps.append(step)
        }

        ProgressCalculator.syncProgress(for: task)

        if enableDueReminder, hasDueDate {
            let reminder = Reminder(type: .dueDate, scheduledAt: dueDate, task: task)
            modelContext.insert(reminder)
            task.reminders.append(reminder)
        }

        if enableProgressReminder {
            let progressDate = NotificationService.defaultProgressCheckDate(for: task) ?? Date.now.addingTimeInterval(3600)
            let reminder = Reminder(type: .progress, scheduledAt: progressDate, task: task)
            modelContext.insert(reminder)
            task.reminders.append(reminder)
        }

        if customReminderEnabled {
            let reminder = Reminder(type: .custom, scheduledAt: customReminderDate, task: task)
            modelContext.insert(reminder)
            task.reminders.append(reminder)
        }

        try? modelContext.save()

        Task {
            if enableDueReminder, hasDueDate {
                await NotificationService.shared.scheduleDeadlineReminder(for: task)
            }
            if enableProgressReminder {
                let progressDate = NotificationService.defaultProgressCheckDate(for: task)
                await NotificationService.shared.scheduleProgressReminder(for: task, at: progressDate)
            }
            if customReminderEnabled {
                await NotificationService.shared.scheduleCustomReminder(for: task, at: customReminderDate)
            }
        }

        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [JobTask.self, TaskStep.self, TaskReport.self, Reminder.self, Category.self], inMemory: true)
}
