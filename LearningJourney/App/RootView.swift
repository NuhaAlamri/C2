import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Learning Journey")
            Text("\(0) days")
            Text("\(1) days")
            Text("\(3) days")
        }
    }
}

#Preview {
    RootView()
}
