import Foundation

enum GoalDuration: String, Codable, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: Self { self }

    /// الاسم اللي ينعرض للمستخدم
    var title: LocalizedStringResource {
        switch self {
        case .week:  "Week"
        case .month: "Month"
        case .year:  "Year"
        }
    }

    /// أقصى عدد تجميد مسموح
    var freezeLimit: Int {
        switch self {
        case .week:  2
        case .month: 8
        case .year:  96
        }
    }

    /// طول المدة
    private var length: (component: Calendar.Component, value: Int) {
        switch self {
        case .week:  (.day, 7)
        case .month: (.month, 1)   // DECISION: مؤقت حتى T39
        case .year:  (.year, 1)    // DECISION: مؤقت حتى T39
        }
    }

    /// لحظة انتهاء الهدف: منتصف ليل اليوم اللي بعد آخر يوم
    func endDate(from start: Date, calendar: Calendar = .current) -> Date {
        let startDay = calendar.startOfDay(for: start)
        return calendar.date(byAdding: length.component, value: length.value, to: startDay)!
    }
}
