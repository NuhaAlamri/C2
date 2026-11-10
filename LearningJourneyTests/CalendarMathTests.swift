import Testing
import Foundation
@testable import LearningJourney

@MainActor
struct CalendarMathTests {

    let sunday = Fixtures.calendar          // الأسبوع يبدأ بالأحد
    var monday: Calendar {                  // نفس التقويم بس يبدأ بالاثنين
        var c = Fixtures.calendar
        c.firstWeekday = 2
        return c
    }

    func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        sunday.date(from: DateComponents(year: y, month: m, day: d))!
    }

    @Test func sketchWeekIsSunday20ToSaturday26() {
        let days = CalendarMath.weekDays(containing: Fixtures.october(24), calendar: sunday)
        #expect(days.count == 7)
        #expect(days.first == date(2024, 10, 20))
        #expect(days.last == date(2024, 10, 26))
    }

    @Test func weekStartsMondayWhenDeviceSaysSo() {
        let days = CalendarMath.weekDays(containing: Fixtures.october(24), calendar: monday)
        #expect(days.first == date(2024, 10, 21))
    }

    @Test func symbolsFollowFirstWeekday() {
        #expect(CalendarMath.weekdaySymbols(calendar: sunday) == ["S", "M", "T", "W", "T", "F", "S"])
        #expect(CalendarMath.weekdaySymbols(calendar: monday) == ["M", "T", "W", "T", "F", "S", "S"])
    }

    @Test func monthsCrossTheYearEnd() {
        let months = CalendarMath.months(from: date(2024, 10, 20), to: date(2025, 2, 10), calendar: sunday)
        #expect(months.count == 5)                    // أكتوبر، نوفمبر، ديسمبر، يناير، فبراير
        #expect(months.first == date(2024, 10, 1))   // تبدأ من يوم 1
        #expect(months.last == date(2025, 2, 1))
    }

    @Test func februaryInLeapYearHas29Days() {
        #expect(CalendarMath.days(inMonth: date(2024, 2, 10), calendar: sunday).count == 29)
        #expect(CalendarMath.days(inMonth: date(2025, 2, 10), calendar: sunday).count == 28)
    }

    @Test func leadingBlanksForOctober2024() {
        // 1 أكتوبر 2024 = الثلاثاء
        #expect(CalendarMath.leadingBlanks(for: date(2024, 10, 15), calendar: sunday) == 2)
        #expect(CalendarMath.leadingBlanks(for: date(2024, 10, 15), calendar: monday) == 1)
    }

    @Test func monthStartingOnSundayWithMondayFirst() {
        // 1 سبتمبر 2024 = الأحد ← آخر خانة في الصف
        #expect(CalendarMath.leadingBlanks(for: date(2024, 9, 1), calendar: monday) == 6)
    }
}
