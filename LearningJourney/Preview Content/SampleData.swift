import SwiftUI
import SwiftData

/// يجهّز قاعدة بيانات مؤقتة للمعاينات
struct SampleData: PreviewModifier {

    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer(
            for: Goal.self, DayLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        Fixtures.currentDay.insert(into: container.mainContext)
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}

#Preview("Sample data", traits: .sampleData) {
    @Previewable @Query(sort: \DayLog.day) var logs: [DayLog]

    List(logs) { log in
        HStack {
            Text(log.day, format: .dateTime.weekday(.wide).day().month())
            Spacer()
            Text(log.kind == .learned ? "Learned" : "Freezed")
                .foregroundStyle(log.kind == .learned ? Color.learned : Color.freeze)
        }
    }
}
