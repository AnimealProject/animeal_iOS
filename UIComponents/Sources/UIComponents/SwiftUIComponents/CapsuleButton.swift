import SwiftUI

public struct CapsuleButton: View {
    let title: String
    let font: Font
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let height: CGFloat
    let action: () -> Void

    public init(
        title: String,
        font: Font,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        borderWidth: CGFloat = 1,
        height: CGFloat = 50,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.height = height
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    Capsule()
                        .fill(backgroundColor)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        CapsuleButton(
            title: "Cancel",
            font: .system(size: 16, weight: .bold),
            foregroundColor: .blue,
            backgroundColor: .white,
            borderColor: .blue
        ) { }
        CapsuleButton(
            title: "Reject",
            font: .system(size: 16, weight: .bold),
            foregroundColor: .white,
            backgroundColor: .blue,
            borderColor: .blue
        ) { }
    }
    .padding()
}
