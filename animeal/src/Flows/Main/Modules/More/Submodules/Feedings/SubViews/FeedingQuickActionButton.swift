import SwiftUI
import Style

struct FeedingQuickActionButton: View {
    enum Status {
        case approved
        case rejected
    }

    @EnvironmentObject private var style: StyleEngine

    private let action: () -> Void
    private let status: Status
    private let width: CGFloat

    private var image: ImageAsset {
        switch status {
        case .approved:
            Asset.Images.approve
        case .rejected:
            Asset.Images.reject
        }
    }

    private var text: String {
        switch status {
        case .approved:
            "Approve"
        case .rejected:
            "Reject"
        }
    }

    private var textColor: Color {
        switch status {
        case .approved:
            style.colors.alwaysLight.color
        case .rejected:
            style.colors.accent.color
        }
    }

    private var componentColor: Color {
        switch status {
        case .approved:
            style.colors.accent.color
        case .rejected:
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
        FeedingQuickActionButton(status: .approved, width: 77) { }
        FeedingQuickActionButton(status: .rejected, width: 77) { }
    }
    .frame(height: 113)
    .padding()
    .environmentObject(StyleDefaultEngine() as StyleEngine)
}
