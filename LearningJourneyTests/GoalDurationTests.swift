import Testing
import Foundation
@testable import LearningJourney

struct GoalDurationTests {

    // تقويم ثابت: النتيجة ما تتغير حسب جهاز اللي يشغّل الاختبار
    let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .gmt
        return c
    }()

    // دالة مساعدة تصنع تاريخ بسهولة
    func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d, hour: hour))!
    }

    @Test(arguments: zip(GoalDuration.allCases, [2, 8, 96]))
    func freezeLimit(duration: GoalDuration, expected: Int) {
        #expect(duration.freezeLimit == expected)
    }

    @Test func weekEndsSevenDaysAfterStartOfDay() {
        let start = date(2026, 11, 10, hour: 15)   // الثلاثاء 3 العصر
        let end = GoalDuration.week.endDate(from: start, calendar: calendar)
        #expect(end == date(2026, 11, 17))         // منتصف ليل اليوم الثامن
    }

    @Test func monthFromJan31EndsFeb28() {
        let start = date(2026, 1, 31)
        let end = GoalDuration.month.endDate(from: start, calendar: calendar)
        #expect(end == date(2026, 2, 28))
    }

    @Test func savedNamesNeverChange() {
        #expect(GoalDuration.allCases.map(\.rawValue) == ["week", "month", "year"])
    }
}
