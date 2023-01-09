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

    public static var fullScreen: BottomSheetConfiguration {
        return .init(
            maxDimmedAlpha: 0.6,
            defaultHeight: UIScreen.main.bounds.height / 2,
            dismissibleHeight: UIScreen.main.bounds.height / 2 - 150,
            maximumContainerHeight: UIScreen.main.bounds.height - 50
        )
    }
    
    public static var attachPhotoScreen: BottomSheetConfiguration {
        return .init(
            maxDimmedAlpha: 0.6,
            defaultHeight: 345,
            dismissibleHeight: 150,
            maximumContainerHeight: 345
        )
    }
}
