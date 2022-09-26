import UIKit

public struct BottomSheetConfiguration {
    public let maxDimmedAlpha: CGFloat
    public let defaultHeight: CGFloat
    public let dismissibleHeight: CGFloat
    public let maximumContainerHeight: CGFloat

    public init(
        maxDimmedAlpha: CGFloat,
        defaultHeight: CGFloat,
        dismissibleHeight: CGFloat,
        maximumContainerHeight: CGFloat
    ) {
        self.maxDimmedAlpha = maxDimmedAlpha
        self.defaultHeight = defaultHeight
        self.dismissibleHeight = dismissibleHeight
        self.maximumContainerHeight = maximumContainerHeight
    }

    public static var `default`: BottomSheetConfiguration {
        return .init(
            maxDimmedAlpha: 0.6,
            defaultHeight: 240,
            dismissibleHeight: 150,
            maximumContainerHeight: UIScreen.main.bounds.height / 2
        )
    }
}
