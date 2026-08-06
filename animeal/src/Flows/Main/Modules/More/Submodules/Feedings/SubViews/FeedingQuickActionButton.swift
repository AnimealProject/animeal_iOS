import SwiftUI
import Style

struct FeedingQuickActionButton: View {
    enum Status {
        case approve
        case reject
    }

    private enum Constants {
        static let approveText = L10n.Feeding.approve
        static let rejectText = L10n.Feeding.reject
    }

    @EnvironmentObject private var style: StyleEngine

    private let action: () -> Void
    private let status: Status
    private let width: CGFloat

    private var image: ImageAsset {
        switch status {
        case .approve:
            Asset.Images.approve
        case .reject:
            Asset.Images.reject
        }
    }

    private var text: String {
        switch status {
        case .approve:
            Constants.approveText
        case .reject:
            Constants.rejectText
        }
    }

    private var textColor: Color {
        switch status {
        case .approve:
            style.colors.alwaysLight.color
        case .reject:
            style.colors.accent.color
        }
    }

    private var componentColor: Color {
        switch status {
        case .approve:
            style.colors.accent.color
        case .reject:
            style.colors.alwaysLight.color
        }
    }

    init(status: Status, width: CGFloat, action: @escaping () -> Void) {
        self.status = status
        self.width = width
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                image.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(textColor)
                Text(text)
                    .font(style.fonts.secondary.bold(14).font)
                    .foregroundColor(textColor)
            }
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .compositingGroup()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(componentColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style.colors.accent.color, lineWidth: 1)
            )
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        FeedingQuickActionButton(status: .approve, width: 77) { }
        FeedingQuickActionButton(status: .reject, width: 77) { }
    }
    .frame(height: 113)
    .padding()
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
