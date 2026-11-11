import Testing
import Foundation
@testable import LearningJourney

@MainActor
struct StreakEngineTests {

    func snapshot(_ state: Fixtures.State) -> ActivitySnapshot {
        StreakEngine.snapshot(
            start: state.start, duration: state.duration,
            logs: state.entries, now: state.now,
            calendar: Fixtures.calendar
        )
    }

    @Test func currentDayMatchesSketch() {
        let s = snapshot(Fixtures.currentDay)
        #expect(s.streak == 4)
        #expect(s.freezesUsed == 0)
        #expect(s.goalState == .active)
        #expect(s.canLog)
        #expect(s.canFreeze)
    }
}
