import UIKit

public class TapGestureRecognizer: UITapGestureRecognizer {
    private let tapAction: ((UITapGestureRecognizer) -> Void)?

    public init(
        tapCount: Int = 1,
        fingerCount: Int = 1,
        action: ((UITapGestureRecognizer) -> Void)?
    ) {
        self.tapAction = action
        super.init(target: nil, action: nil)

        numberOfTapsRequired = tapCount
        numberOfTouchesRequired = fingerCount

        addTarget(self, action: #selector(TapGestureRecognizer.didTap(_:)))
    }

    @objc public func didTap(_ tapGesture: UITapGestureRecognizer) {
        if tapGesture.state == .ended {
            tapAction?(tapGesture)
        }
    }
}
