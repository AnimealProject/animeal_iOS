import UIKit
import Style

final class ShimmerGradientAnimatedView: UIView {
    // MARK: - UI properties
    let gradientLayer = CAGradientLayer()

    // MARK: - Animation properties
    let animationDirection: ShimmerComponents.Direction

    let animationValues: (CGRect) -> [[CGFloat]]
    let animationKeyTimes: (CGRect, ((CGRect) -> CGRect)?) -> [NSNumber]

    // MARK: - Colors
    var primaryColor: UIColor = .white {
        didSet {
            updateColors()
        }
    }

    var secondaryColor: UIColor = .init(white: 0.9, alpha: 1.0) {
        didSet {
            updateColors()
        }
    }

    // MARK: - Initialization
    init(
        animationDirection: ShimmerComponents.Direction,
        animationValues: @escaping (CGRect) -> [[CGFloat]],
        animationKeyTimes: @escaping (CGRect, ((CGRect) -> CGRect)?) -> [NSNumber]
    ) {
        self.animationDirection = animationDirection
        self.animationValues = animationValues
        self.animationKeyTimes = animationKeyTimes
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = frame
    }

    // MARK: - Animate
    func animateOnce(with duration: TimeInterval) {
        CATransaction.begin()
        let animation = CAKeyframeAnimation(
            keyPath: #keyPath(CAGradientLayer.locations)
        )
        animation.values = calculateAnimationValues()
        animation.keyTimes = calculateKeyTimes()
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunctions = [.init(name: .linear)]
        gradientLayer.add(animation, forKey: "animateGradient")
        CATransaction.commit()
    }

    func startAnimation(withDuration duration: TimeInterval) {
        let animation = CAKeyframeAnimation(
            keyPath: #keyPath(CAGradientLayer.locations)
        )
        animation.values = calculateAnimationValues()
        animation.keyTimes = calculateKeyTimes()
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.repeatCount = .infinity
        animation.timingFunctions = [.init(name: .linear)]
        gradientLayer.add(animation, forKey: "animateGradient")
    }

    func stopAnimation() {
        gradientLayer.removeAllAnimations()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateColors()
    }
}

private extension ShimmerGradientAnimatedView {
    // MARK: - Setup
    func setup() {
        updateColors()
        gradientLayer.startPoint = animationDirection.startPoint
        gradientLayer.endPoint = animationDirection.endPoint
        gradientLayer.locations = .initialLocations
        layer.addSublayer(gradientLayer)
    }

    func updateColors() {
        gradientLayer.colors = [
            secondaryColor.cgColor,
            primaryColor.cgColor,
            secondaryColor.cgColor
        ]
    }

    // MARK: - Animation calculation
    func calculateAnimationValues() -> [[CGFloat]] {
        animationValues(frame)
    }

    func calculateKeyTimes() -> [NSNumber] {
        return animationKeyTimes(frame) { [weak self] rect in
            guard let self = self else { return rect }
            return self.convert(rect, to: self.window)
        }
    }
}

private extension Array where Element == NSNumber {
    static var initialLocations: [NSNumber] {
        [1.0, 1.0, 1.0]
    }
}
