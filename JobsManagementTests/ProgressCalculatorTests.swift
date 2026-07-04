import XCTest
@testable import JobsManagement

final class ProgressCalculatorTests: XCTestCase {

    func testCalculateProgressEmptySteps() {
        XCTAssertEqual(ProgressCalculator.calculateProgress(from: []), 0)
    }

    func testCalculateProgressHalfCompleted() {
        let steps = [
            TaskStep(title: "A", orderIndex: 0, status: .completed),
            TaskStep(title: "B", orderIndex: 1, status: .pending),
        ]
        XCTAssertEqual(ProgressCalculator.calculateProgress(from: steps), 50)
    }

    func testCalculateProgressAllCompleted() {
        let steps = [
            TaskStep(title: "A", orderIndex: 0, status: .completed),
            TaskStep(title: "B", orderIndex: 1, status: .completed),
        ]
        XCTAssertEqual(ProgressCalculator.calculateProgress(from: steps), 100)
    }

    func testIsBehindScheduleWhenPastDueAndIncomplete() {
        let task = JobTask(
            title: "Late task",
            dueDate: Date.now.addingTimeInterval(-3600),
            progressPercent: 30
        )
        XCTAssertTrue(ProgressCalculator.isBehindSchedule(task: task))
    }

    func testIsNotBehindScheduleWhenCompleted() {
        let task = JobTask(
            title: "Done",
            dueDate: Date.now.addingTimeInterval(-3600),
            status: .completed,
            progressPercent: 100
        )
        XCTAssertFalse(ProgressCalculator.isBehindSchedule(task: task))
    }

    func testShouldTriggerProgressReminderWhenBehind() {
        let dueDate = Date.now.addingTimeInterval(86400)
        let task = JobTask(
            title: "Behind",
            dueDate: dueDate,
            status: .inProgress,
            progressPercent: 10,
            estimatedDuration: 86400 * 2
        )
        let reference = dueDate.addingTimeInterval(-86400 * 0.6)
        XCTAssertTrue(
            ProgressCalculator.shouldTriggerProgressReminder(task: task, referenceDate: reference)
        )
    }
}
