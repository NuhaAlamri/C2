import Foundation

/// حسابات تواريخ للتقويم وشريط الأسبوع
enum CalendarMath {

    /// أيام الأسبوع السبعة اللي فيها التاريخ، تبدأ من أول يوم في الأسبوع حسب الجهاز
    static func weekDays(containing date: Date, calendar: Calendar = .current) -> [Date] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
    }

    /// حروف الأيام بالترتيب الصحيح، مثل S M T W T F S
    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.veryShortWeekdaySymbols   // دائماً تبدأ بالأحد
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    /// أول يوم من كل شهر بين تاريخين، شاملة الشهرين
    static func months(from start: Date, to end: Date, calendar: Calendar = .current) -> [Date] {
        guard let first = calendar.dateInterval(of: .month, for: start)?.start,
              let last = calendar.dateInterval(of: .month, for: end)?.start else { return [] }

        var result: [Date] = []
        var month = first
        while month <= last {
            result.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    /// كل أيام الشهر اللي فيه التاريخ
    static func days(inMonth date: Date, calendar: Calendar = .current) -> [Date] {
        guard let month = calendar.dateInterval(of: .month, for: date),
              let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month.start) }
    }

    /// كم خانة فاضية قبل يوم 1 في شبكة الشهر
    static func leadingBlanks(for date: Date, calendar: Calendar = .current) -> Int {
        guard let first = calendar.dateInterval(of: .month, for: date)?.start else { return 0 }
        let weekday = calendar.component(.weekday, from: first)   // 1 = الأحد … 7 = السبت
        return (weekday - calendar.firstWeekday + 7) % 7
    }
}
