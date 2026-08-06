import SwiftUI
import Style

struct FeedingImagePlaceholder: View {
    var body: some View {
        Asset.Colors.backgroundSecondary.swiftUIColor
            .overlay(ProgressView())
    }
}
