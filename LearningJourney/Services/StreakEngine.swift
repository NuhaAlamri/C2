import Foundation

/// نسخة بسيطة من DayLog، بدون SwiftData
struct LogEntry: Equatable {
    let day: Date
    let loggedAt: Date
    let kind: DayLog.Kind
}

extension DayLog {
    var entry: LogEntry { LogEntry(day: day, loggedAt: loggedAt, kind: kind) }
}

/// كل قواعد السلسلة في مكان واحد
enum StreakEngine {
    
    /// أقصى فرق مسموح بين تسجيلين: 32 ساعة بالثواني
    static let maxGap: TimeInterval = 32 * 60 * 60
    
    static func snapshot(
        start: Date,
        duration: GoalDuration,
        logs: [LogEntry],
        now: Date,
        calendar: Calendar = .current
    ) -> ActivitySnapshot {
        let today = calendar.startOfDay(for: now)
        let end = duration.endDate(from: start, calendar: calendar)
        let goalState: ActivitySnapshot.GoalState =
        now < end ? .active : goalResult(logs: logs, end: end)
        let chain = currentChain(logs, at: min(now, end))
        
        return ActivitySnapshot(
            today: today,
            streak: chain.count,
            freezesUsed: logs.filter { $0.kind == .freezed }.count,
            freezeLimit: duration.freezeLimit,
            todayKind: logs.first { $0.day == today }?.kind,
            goalState: goalState,
            dayKinds: Dictionary(logs.map { ($0.day, $0.kind) },
                                 uniquingKeysWith: { _, latest in latest })
        )
    }
    
    /// السجلات من آخر انقطاع لين اللحظة المعطاة
    static func currentChain(_ logs: [LogEntry], at moment: Date) -> [LogEntry] {
        let sorted = logs.sorted { $0.loggedAt < $1.loggedAt }
        guard let last = sorted.last,
              moment.timeIntervalSince(last.loggedAt) <= maxGap else { return [] }
        
        var chain = [last]
        for log in sorted.dropLast().reversed() {
            guard chain[0].loggedAt.timeIntervalSince(log.loggedAt) <= maxGap else { break }
            chain.insert(log, at: 0)
        }
        return chain
    }
    
    /// DECISION (قرار المشرف): الهدف ناجح إذا ما انكسرت السلسلة لين نهاية المدة
    static func goalResult(logs: [LogEntry], end: Date) -> ActivitySnapshot.GoalState {
        guard !logs.isEmpty else { return .notMet }
        
        let moments = logs.map(\.loggedAt).sorted() + [end]
        for (earlier, later) in zip(moments, moments.dropFirst())
                where later.timeIntervalSince(earlier) > maxGap {
            return .notMet
        }
        return .completed
    }
}
