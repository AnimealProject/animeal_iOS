import UIKit

final class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard self.state != .began else { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
