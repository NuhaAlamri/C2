import Testing
import Foundation
import SwiftData
@testable import LearningJourney

@MainActor
struct ModelTests {
    let container: ModelContainer
    var context: ModelContext { container.mainContext }

    init() throws {
        container = try ModelContainer(
            for: Goal.self, DayLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func dayIsStartOfDay() {
        let log = DayLog(kind: .learned)
        #expect(log.day == Calendar.current.startOfDay(for: log.loggedAt))
    }

    @Test func goalKeepsItsLogs() throws {
        let goal = Goal(topic: "Swift", duration: .week)
        context.insert(goal)
        goal.logs.append(DayLog(kind: .learned))
        try context.save()

        let saved = try context.fetch(FetchDescriptor<Goal>())
        #expect(saved.count == 1)
        #expect(saved.first?.logs.count == 1)
        #expect(saved.first?.logs.first?.goal === goal)
    }

    @Test func deletingGoalKeepsHistory() throws {
        let goal = Goal(topic: "Swift", duration: .week)
        context.insert(goal)
        goal.logs.append(DayLog(kind: .learned))
        try context.save()

        context.delete(goal)
        try context.save()

        let logs = try context.fetch(FetchDescriptor<DayLog>())
        #expect(logs.count == 1)          // التسجيل باقي في التقويم
        #expect(logs.first?.goal == nil)  // بس صار بدون هدف
    }

    @Test func onlyOneLogPerDay() throws {
        context.insert(DayLog(kind: .learned))
        context.insert(DayLog(kind: .freezed))
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<DayLog>()) == 1)
    }

    @Test func newGoalIsActive() {
        #expect(Goal(topic: "Swift", duration: .week).isActive)
    }
}
