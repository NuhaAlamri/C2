import Foundation
import SwiftData

@Model
final class Goal {
    var topic: String
    var duration: GoalDuration
    var startDate: Date
    var endedAt: Date?
    var endReason: EndReason?

    @Relationship(inverse: \DayLog.goal)
    var logs: [DayLog] = []

    init(topic: String, duration: GoalDuration, startDate: Date = .now) {
        self.topic = topic
        self.duration = duration
        self.startDate = startDate
    }

    /// الهدف الحالي هو اللي ما انتهى
    var isActive: Bool { endedAt == nil }
}

extension Goal {
    enum EndReason: String, Codable {
        case completed   // خلصت المدة
        case replaced    // المستخدم حدّث الهدف
    }
}
