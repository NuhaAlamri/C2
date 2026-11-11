import Testing
import Foundation
@testable import LearningJourney

@MainActor
struct StreakEngineTests {

    let calendar = Fixtures.calendar

    // MARK: - Helpers

    /// تسجيل في يوم وساعة من أكتوبر 2024
    func log(_ day: Int, at hour: Int = 9, _ kind: DayLog.Kind = .learned) -> LogEntry {
        let moment = Fixtures.october(day, hour: hour)
        return LogEntry(day: calendar.startOfDay(for: moment), loggedAt: moment, kind: kind)
    }

    /// بداية يوم من أكتوبر 2024
    func day(_ d: Int) -> Date {
        calendar.startOfDay(for: Fixtures.october(d))
    }

    /// لقطة لهدف أسبوعي يبدأ 20 أكتوبر (إلا لو حددنا غير كذا)
    func snapshot(
        _ logs: [LogEntry],
        now: Date,
        start: Date? = nil,
        duration: GoalDuration = .week
    ) -> ActivitySnapshot {
        StreakEngine.snapshot(
            start: start ?? Fixtures.october(20),
            duration: duration,
            logs: logs,
            now: now,
            calendar: calendar
        )
    }

    /// أسبوع كامل: تسجيل كل يوم من 20 إلى 26
    var fullWeek: [LogEntry] { (20...26).map { log($0) } }

    // MARK: - Sketch states (قرارات المشرف)

    struct Expected {
        let state: Fixtures.State
        let streak: Int
        let freezesUsed: Int
        let todayKind: DayLog.Kind?
        let canLog: Bool
        let canFreeze: Bool
        let goal: ActivitySnapshot.GoalState
    }

    @Test func sketchStates() {
        let table: [Expected] = [
            .init(state: Fixtures.currentDay,    streak: 4, freezesUsed: 0, todayKind: nil,      canLog: true,  canFreeze: true,  goal: .active),
            .init(state: Fixtures.learnedToday,  streak: 5, freezesUsed: 0, todayKind: .learned, canLog: false, canFreeze: false, goal: .active),
            .init(state: Fixtures.freezedToday,  streak: 5, freezesUsed: 1, todayKind: .freezed, canLog: false, canFreeze: false, goal: .active),
            .init(state: Fixtures.noFreezesLeft, streak: 5, freezesUsed: 2, todayKind: .freezed, canLog: false, canFreeze: false, goal: .active),
            .init(state: Fixtures.goalCompleted, streak: 5, freezesUsed: 2, todayKind: nil,      canLog: false, canFreeze: false, goal: .completed),
            .init(state: Fixtures.goalNotMet,    streak: 2, freezesUsed: 2, todayKind: nil,      canLog: false, canFreeze: false, goal: .notMet),
        ]

        for e in table {
            let s = snapshot(e.state.entries, now: e.state.now,
                             start: e.state.start, duration: e.state.duration)
            let name = e.state.name
            #expect(s.streak == e.streak, "\(name)")
            #expect(s.freezesUsed == e.freezesUsed, "\(name)")
            #expect(s.todayKind == e.todayKind, "\(name)")
            #expect(s.canLog == e.canLog, "\(name)")
            #expect(s.canFreeze == e.canFreeze, "\(name)")
            #expect(s.goalState == e.goal, "\(name)")
        }
    }

    // MARK: - 32-hour rule

    @Test func streakSurvives31Hours() {
        let s = snapshot([log(20)], now: Fixtures.october(21, hour: 16))
        #expect(s.streak == 1)
    }

    @Test func streakSurvivesExactly32Hours() {
        let s = snapshot([log(20)], now: Fixtures.october(21, hour: 17))
        #expect(s.streak == 1)
    }

    @Test func streakBreaksAfter33Hours() {
        let s = snapshot([log(20)], now: Fixtures.october(21, hour: 18))
        #expect(s.streak == 0)
    }

    @Test func consecutiveDays39HoursApartBreakTheStreak() {
        // 20 الساعة 8 الصبح، ثم 21 الساعة 11 بالليل = 39 ساعة
        let s = snapshot([log(20, at: 8), log(21, at: 23)], now: Fixtures.october(21, hour: 23))
        #expect(s.streak == 1)
    }

    // MARK: - Freeze

    @Test func freezeKeepsTheChainAndCounts() {
        let s = snapshot([log(20), log(21, .freezed), log(22)], now: Fixtures.october(22, hour: 10))
        #expect(s.streak == 3)
    }

    @Test func missedDayWithoutFreezeBreaksTheChain() {
        let s = snapshot([log(20), log(22)], now: Fixtures.october(22, hour: 10))
        #expect(s.streak == 1)
    }

    @Test func cannotFreezeWhenWeekLimitIsUsed() {
        let s = snapshot([log(20, .freezed), log(21, .freezed)], now: Fixtures.october(22, hour: 8))
        #expect(s.freezesUsed == 2)
        #expect(s.canLog)
        #expect(!s.canFreeze)
    }

    @Test func monthGoalAllowsMoreFreezes() {
        let s = snapshot([log(20, .freezed), log(21, .freezed)],
                         now: Fixtures.october(22, hour: 8), duration: .month)
        #expect(s.freezeLimit == 8)
        #expect(s.canFreeze)
    }

    // MARK: - Midnight

    @Test func buttonsReEnableAtMidnight() {
        let logs = [log(22, at: 23)]
        let lateNight = snapshot(logs, now: Fixtures.october(22, hour: 23))
        let midnight  = snapshot(logs, now: Fixtures.october(23, hour: 0))

        #expect(!lateNight.canLog)
        #expect(midnight.canLog)
        #expect(midnight.todayKind == nil)
        #expect(midnight.streak == 1)   // السلسلة باقية
    }

    // MARK: - Goal end

    @Test func goalIsActiveUntilMidnightOfDay8() {
        let s = snapshot(fullWeek, now: Fixtures.october(26, hour: 23))
        #expect(s.goalState == .active)
    }

    @Test func goalEndsAtMidnightOfDay8() {
        let s = snapshot(fullWeek, now: Fixtures.october(27, hour: 0))
        #expect(s.goalState == .completed)
        #expect(!s.canLog)
        #expect(!s.canFreeze)
    }

    @Test func endedGoalKeepsItsFinalStreak() {
        let s = snapshot(fullWeek, now: Fixtures.october(31, hour: 12))   // بعد النهاية بأيام
        #expect(s.streak == 7)
        #expect(s.goalState == .completed)
    }

    @Test func breakInTheMiddleMeansNotMet() {
        let logs = [log(20), log(21)] + (23...26).map { log($0) }   // 22 فات
        let s = snapshot(logs, now: Fixtures.october(27, hour: 0))
        #expect(s.goalState == .notMet)
        #expect(s.streak == 4)   // السلسلة الجديدة 23–26
    }

    @Test func stoppingBeforeTheEndMeansNotMet() {
        // آخر تسجيل 25 الساعة 9، والنهاية 27 الساعة 12 بالليل = 39 ساعة
        let s = snapshot((20...25).map { log($0) }, now: Fixtures.october(27, hour: 0))
        #expect(s.goalState == .notMet)
    }

    @Test func goalWithNoLogsIsNotMet() {
        let s = snapshot([], now: Fixtures.october(27, hour: 0))
        #expect(s.goalState == .notMet)
    }

    // MARK: - Data

    @Test func orderOfLogsDoesNotMatter() {
        let logs = [log(20), log(21), log(22)]
        let now = Fixtures.october(22, hour: 10)
        #expect(snapshot(logs, now: now) == snapshot(Array(logs.reversed()), now: now))
    }

    @Test func dayKindsColorTheWeek() {
        let state = Fixtures.freezedToday
        let s = snapshot(state.entries, now: state.now)
        #expect(s.kind(on: day(22)) == .learned)
        #expect(s.kind(on: day(24)) == .freezed)
        #expect(s.kind(on: day(25)) == nil)   // يوم جاي
    }
}
