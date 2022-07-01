import Foundation
import UIKit

public struct KeyboardData {
    public let keyboardRect: CGRect
    public let animationDuration: TimeInterval
    public let animationCurve: UIView.AnimationCurve

    public var isHiding: Bool {
        return keyboardRect == .zero
    }

    /// Conversion between the animation curve and the animation options, required by `UIView.animate(...)`
    public var animationCurveOption: UIView.AnimationOptions {
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
