import UIKit
import Style

protocol ActivityIndicatorAnimatable {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor)
}

final class ActivityIndicatorAnimation: ActivityIndicatorAnimatable {
    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards

        let circle = ActivityIndicatorShape.stroke.layerWith(size: size, color: color)
        let frame = CGRect(
            x: (layer.bounds.width - size.width) / 2,
            y: (layer.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )

        circle.frame = frame
        circle.add(groupAnimation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

enum ActivityIndicatorShape {
    case circle
    case stroke

    func layerWith(size: CGSize, color: UIColor) -> CALayer {
        let layer = CAShapeLayer()
        let path = UIBezierPath()

        switch self {
        case .circle:
            path.addArc(
                withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: 0,
                endAngle: CGFloat(2 * Double.pi),
                clockwise: false
            )
            layer.fillColor = color.cgColor
        case .stroke:
            path.addArc(
                withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: -(.pi / 2),
                endAngle: .pi + .pi / 2,
                clockwise: true
            )
            layer.fillColor = nil
            layer.strokeColor = color.cgColor
            layer.lineWidth = 4
        }

        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        return layer
    }
}

public enum ActivityIndicatorType: CaseIterable {
    case circleStrokeSpin

    func animation() -> ActivityIndicatorAnimatable {
        switch self {
        case .circleStrokeSpin:
            return ActivityIndicatorAnimation()
        }
    }
}

public typealias FadeInAnimation = (UIView) -> Void
public typealias FadeOutAnimation = (UIView, @escaping () -> Void) -> Void

public final class ActivityIndicatorView: UIView {
    public let type: ActivityIndicatorType
    public let color: UIColor
    public let padding: CGFloat

    private(set) public var isAnimating: Bool = false

    // MARK: - Initialization
    public init(
        frame: CGRect,
        type: ActivityIndicatorType = .circleStrokeSpin,
        color: UIColor = Asset.Colors.backgroundPrimary.color,
        padding: CGFloat = 0.0
    ) {
        self.type = type
        self.color = color
        self.padding = padding
        super.init(frame: frame)
        isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }

    public override var bounds: CGRect {
        didSet {
            if oldValue != bounds && isAnimating {
                setupAnimation()
            }
        }
    }

    public func startAnimating() {
        guard !isAnimating else {
            return
        }
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setupAnimation()
    }

    public func stopAnimating() {
        guard isAnimating else {
            return
        }
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }

    // MARK: - Set up
    private func setupAnimation() {
        let animation: ActivityIndicatorAnimatable = type.animation()
        var animationRect = frame.inset(
            by: UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: padding
            )
        )
        let minEdge = min(animationRect.width, animationRect.height)

        layer.sublayers = nil
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        animation.setUpAnimation(in: layer, size: animationRect.size, color: color)
    }
}

public extension ActivityIndicatorView {
    static var fadeInAnimation: FadeInAnimation = { view in
        view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            view.alpha = 1
        }
    }

    static var fadeOutAnimation: FadeOutAnimation = { view, complete in
        UIView.animate(
            withDuration: 0.25,
            animations: {
                view.alpha = 0
            },
            completion: { completed in
                if completed { complete() }
            }
        )
    }
}
