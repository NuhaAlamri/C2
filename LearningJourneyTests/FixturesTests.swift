import Testing
import Foundation
import SwiftData
@testable import LearningJourney

@MainActor
struct FixturesTests {

    @Test func sketchTodayIsThursday() {
        let weekday = Fixtures.calendar.component(.weekday, from: Fixtures.october(24))
        #expect(weekday == 5)   // 1 = الأحد … 5 = الخميس
    }

    @Test func everyStateInsertsItsLogs() throws {
        for state in Fixtures.all {
            let container = try ModelContainer(
                for: Goal.self, DayLog.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            let goal = state.insert(into: container.mainContext)
            try container.mainContext.save()

            let learned = goal.logs.filter { $0.kind == .learned }.count
            let freezed = goal.logs.filter { $0.kind == .freezed }.count
            #expect(learned == state.learned.count, "\(state.name)")
            #expect(freezed == state.freezed.count, "\(state.name)")
        }
    }

    @Test func noStateExceedsWeekFreezeLimit() {
        for state in Fixtures.all {
            #expect(state.freezed.count <= GoalDuration.week.freezeLimit, "\(state.name)")
        }
    }
}
