import Foundation
import SwiftData

@Model
final class DayLog {
    #Unique<DayLog>([\.day])

    var day: Date        // بداية اليوم (منتصف الليل)
    var loggedAt: Date   // اللحظة الفعلية للضغط
    var kind: Kind
    var goal: Goal?

    init(kind: Kind, at moment: Date = .now, calendar: Calendar = .current) {
        self.day = calendar.startOfDay(for: moment)
        self.loggedAt = moment
        self.kind = kind
    }
}

extension DayLog {
    enum Kind: String, Codable {
        case learned
        case freezed
    }
}
