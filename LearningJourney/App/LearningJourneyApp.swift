import SwiftUI
import SwiftData

@main
struct LearningJourneyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Goal.self, DayLog.self])
    }
}
