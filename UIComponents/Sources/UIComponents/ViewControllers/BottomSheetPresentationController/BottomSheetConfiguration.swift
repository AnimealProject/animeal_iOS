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
        let safeAreaTopInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let maxHeight = UIScreen.main.bounds.height - safeAreaTopInset
        return .init(
            maxDimmedAlpha: 0.6,
            defaultHeight: maxHeight,
            dismissibleHeight: maxHeight - 150,
            maximumContainerHeight: maxHeight
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
