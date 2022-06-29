import Foundation
import UIKit

public struct KeyboardData {
    let keyboardRect: CGRect
    let animationDuration: TimeInterval
    let animationCurve: UIView.AnimationCurve

    var isHiding: Bool {
        return keyboardRect.height == 0.0
    }

    /// Conversion between the animation curve and the animation options, required by `UIView.animate(...)`
    var animationCurveOption: UIView.AnimationOptions {
        switch self.animationCurve {
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        case .linear:
            return .curveLinear
        @unknown default:
            return .curveLinear
        }
    }
}

public extension KeyboardData {
    init() {
        self.init(keyboardRect: .zero, animationDuration: 0, animationCurve: .linear)
    }
}
