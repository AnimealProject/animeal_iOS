import UIKit

public struct BottomSheetConfiguration {
    public let maxDimmedAlpha: CGFloat
    public let defaultHeight: CGFloat
    public let dismissibleHeight: CGFloat
    public let maximumContainerHeight: CGFloat
    public let intermediateContainerHeight: CGFloat?

    public init(
        maxDimmedAlpha: CGFloat,
        defaultHeight: CGFloat,
        dismissibleHeight: CGFloat,
        maximumContainerHeight: CGFloat,
        intermediateContainerHeight: CGFloat? = nil
    ) {
        self.maxDimmedAlpha = maxDimmedAlpha
        self.defaultHeight = defaultHeight
        self.dismissibleHeight = dismissibleHeight
        self.maximumContainerHeight = maximumContainerHeight
        self.intermediateContainerHeight = intermediateContainerHeight
    }

    ///  `BottomSheetConfiguration.default`  provides default configuration options for a container
    ///  that can be sized to one of three distinct height
    ///  levels: '`minimized'`, `'intermediate'`, and `'fullscreen'`,
    ///  with the intermediate height representing an intermediate size
    ///  between the minimized and fullscreen heights.
    public static var `default`: BottomSheetConfiguration {
        let safeAreaTopInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let maxHeight = UIScreen.main.bounds.height - safeAreaTopInset
        return .init(
            maxDimmedAlpha: 0.6,
            defaultHeight: 240,
            dismissibleHeight: 150,
            maximumContainerHeight: maxHeight,
            intermediateContainerHeight: maxHeight / 2
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
