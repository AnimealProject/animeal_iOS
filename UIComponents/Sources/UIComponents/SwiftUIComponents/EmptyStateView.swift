import SwiftUI
import Style

public struct EmptyStateView: View {
    @EnvironmentObject private var designEngine: StyleEngine

    let image: ImageAsset
    let title: String
    let subtitle: String
    let titleColor: Color
    let subtitleColor: Color

    public init(
        image: ImageAsset,
        title: String,
        subtitle: String,
        titleColor: Color,
        subtitleColor: Color
    ) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(asset: image)

            Text(title)
                .font(designEngine.fonts.primary.bold(28).font)
                .foregroundColor(titleColor)

            Text(subtitle)
                .font(designEngine.fonts.primary.regular(16).font)
                .foregroundColor(subtitleColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Well done") {
    EmptyStateView(
        image: Asset.Images.emptyStateBone,
        title: "Well done!",
        subtitle: "Thank you!\nAll feedings have been reviewed.",
        titleColor: .cyan,
        subtitleColor: .primary
    )
    .padding()
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}

#Preview("Ooops") {
    EmptyStateView(
        image: Asset.Images.emptyStateBone,
        title: "Ooops!",
        subtitle: "There is no items in the list yet.",
        titleColor: .cyan,
        subtitleColor: .primary
    )
    .padding()
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
