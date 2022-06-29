import UIKit
import Foundation

extension Notification {
    func keyboardData(isHiding: Bool) -> KeyboardData {
        guard
            let userInfo = self.userInfo,
            let rect = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect,
            let duration = userInfo["UIKeyboardAnimationDurationUserInfoKey"] as? TimeInterval,
            let animationCurveRaw = userInfo["UIKeyboardAnimationCurveUserInfoKey"] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: animationCurveRaw)
        else {
            return KeyboardData()
        }

        return KeyboardData(
            keyboardRect: isHiding ? .zero : rect,
            animationDuration: duration,
            animationCurve: animationCurve
        )
    }
}
