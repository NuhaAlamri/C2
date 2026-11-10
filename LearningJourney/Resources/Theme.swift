import SwiftUI

// ألوان التطبيق: كلها من ألوان النظام، فتتغير تلقائياً بين Light وDark
extension ShapeStyle where Self == Color {

    /// لون "تعلّمت اليوم"
    static var learned: Color { .orange }

    /// لون "التجميد"
    static var freeze: Color { .cyan }

    /// خلفية البطاقات
    static var card: Color { Color(uiColor: .secondarySystemBackground) }
}


// جدول الخطوط (Sketch → SwiftUI)
// 34 Regular  "Hello"                → .largeTitle
// 34 Bold     "Learner"              → .largeTitle.bold()
// 24 Medium   رقم اليوم في الأسبوع     → .title2.weight(.medium)
// 20 Regular  رقم اليوم في التقويم     → .title3
// 17 Regular  النص العادي والتاريخ    → .body
// 17 Semibold اسم الشهر              → .headline
// 16 Regular  "I want to learn"       → .callout
// 16 Semibold "3 days"                → .callout.weight(.semibold)
// 16 Bold     "Well done!"            → .callout.bold()
// 14          "1 out of 2 Freezes used" → .footnote
// 13 Semibold حروف الأيام M T W        → .footnote.weight(.semibold)
// 12 Regular  "Learned" / "Freezed"   → .caption


#Preview("Theme") {
    VStack(spacing: 16) {
        Text("Learned")
            .font(.largeTitle)
            .foregroundStyle(.learned)

        Text("Freezed")
            .font(.body)
            .foregroundStyle(.freeze)

        Text("Card")
            .padding()
            .background(.card, in: .rect(cornerRadius: 16))
    }
    .padding()
}
