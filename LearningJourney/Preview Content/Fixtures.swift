import Foundation
import SwiftData

/// بيانات ثابتة تعيد حالات Sketch (أسبوع 20–26 أكتوبر 2024، واليوم الخميس 24)
enum Fixtures {

    /// تقويم ثابت: نفس النتيجة على أي جهاز
    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Riyadh")!
        c.locale = Locale(identifier: "en_US")
        c.firstWeekday = 1   // الأحد، مثل Sketch
        return c
    }()

    /// تاريخ في أكتوبر 2024
    static func october(_ day: Int, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2024, month: 10, day: day, hour: hour))!
    }

    /// وصف حالة واحدة
    struct State {
        let name: String
        let start: Date
        let now: Date
        let learned: [Int]   // أيام أكتوبر
        let freezed: [Int]
        var topic = "Swift"
        var duration = GoalDuration.week
    }

    static let currentDay = State(
        name: "Current day - Default",
        start: october(20), now: october(24, hour: 10),
        learned: [20, 21, 22, 23], freezed: []
    )

    static let learnedToday = State(
        name: "Learned today",
        start: october(20), now: october(24, hour: 10),
        learned: [20, 21, 22, 23, 24], freezed: []
    )

    static let freezedToday = State(
        name: "Freezed today",
        start: october(20), now: october(24, hour: 10),
        learned: [20, 21, 22, 23], freezed: [24]
    )

    static let noFreezesLeft = State(
        name: "No Freezes available",
        start: october(20), now: october(24, hour: 10),
        learned: [20, 21, 22], freezed: [23, 24]
    )

    static let goalCompleted = State(
        name: "Activity - Goal Completed",
        start: october(18), now: october(25, hour: 10),
        learned: [20, 21, 22], freezed: [23, 24]
    )

    static let goalNotMet = State(
        name: "Activity - Goal not met",
        start: october(18), now: october(25, hour: 10),
        learned: [20, 21], freezed: [23, 24]
    )

    static let all = [currentDay, learnedToday, freezedToday,
                      noFreezesLeft, goalCompleted, goalNotMet]
}

extension Fixtures.State {
    /// ينشئ الهدف وتسجيلاته داخل قاعدة البيانات
    @discardableResult
    func insert(into context: ModelContext) -> Goal {
        let goal = Goal(topic: topic, duration: duration, startDate: start)
        context.insert(goal)

        for day in learned {
            goal.logs.append(DayLog(kind: .learned, at: Fixtures.october(day), calendar: Fixtures.calendar))
        }
        for day in freezed {
            goal.logs.append(DayLog(kind: .freezed, at: Fixtures.october(day), calendar: Fixtures.calendar))
        }
        return goal
    }
}

extension Fixtures.State {
    /// التسجيلات كـ LogEntry للمحرك والاختبارات
    var entries: [LogEntry] {
        learned.map { entry(day: $0, kind: .learned) }
            + freezed.map { entry(day: $0, kind: .freezed) }
    }

    private func entry(day: Int, kind: DayLog.Kind) -> LogEntry {
        let moment = Fixtures.october(day)
        return LogEntry(day: Fixtures.calendar.startOfDay(for: moment), loggedAt: moment, kind: kind)
    }
}
