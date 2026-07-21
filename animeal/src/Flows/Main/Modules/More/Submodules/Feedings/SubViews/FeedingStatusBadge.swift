import SwiftUI
import Style

struct FeedingStatusBadge: View {
    @EnvironmentObject var style: StyleEngine

    var body: some View {
        HStack {
            Image(systemName: "ellipsis.circle")
                .font(style.fonts.secondary.regular(12).font)
            Text("Pending")
                .font(style.fonts.secondary.regular(12).font)
        }
    }
}

#Preview {
    FeedingStatusBadge()
        .environmentObject(StyleDefaultEngine())
}
