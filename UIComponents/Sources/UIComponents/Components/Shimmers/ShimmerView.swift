import UIKit
import Style

public final class ShimmerView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let animationDuration: TimeInterval = 1.0
        static let visibleAlpha: CGFloat = 1.0
        static let invisibleAlpha: CGFloat = 0.0
    }

    // MARK: - UI properties
    private let animationView: ShimmerGradientAnimatedView
    private var animationMaskView: UIView?

    // MARK: - Animation scheduler
    private var scheduler: ShimmerViewScheduler?

    // MARK: - Colors
    public var primaryColor: UIColor {
        get { animationView.primaryColor }
        set { animationView.primaryColor = newValue }
    }

    public var secondaryColor: UIColor {
        get { animationView.secondaryColor }
        set { animationView.secondaryColor = newValue }
    }

    // MARK: - Initialization
    public init(
        animationDirection: ShimmerComponents.Direction,
        animationValues: @escaping (CGRect) -> [[CGFloat]] =
            ShimmerComponents.Animation.Default.values,
        animationKeyTimes: @escaping (CGRect, ((CGRect) -> CGRect)?) -> [NSNumber] =
            ShimmerComponents.Animation.Default.keyTimes
    ) {
        self.animationView = ShimmerGradientAnimatedView(
            animationDirection: animationDirection,
            animationValues: animationValues,
            animationKeyTimes: animationKeyTimes
        )
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Apply mask
    public func setMask(_ maskView: UIView) {
        animationMaskView = maskView
        maskView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(maskView)
        NSLayoutConstraint.activate([
            maskView.leadingAnchor.constraint(equalTo: leadingAnchor),
            maskView.topAnchor.constraint(equalTo: topAnchor),
            maskView.trailingAnchor.constraint(equalTo: trailingAnchor),
            maskView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        bringSubviewToFront(animationView)
        mask = animationMaskView
    }

    // MARK: - Schedule animation
    public func startAnimation(withScheduler scheduler: ShimmerViewScheduler) {
        guard self.scheduler !== scheduler else {
            return
        }
        self.scheduler?.removeListener(self)
        scheduler.addListener(self)
        self.scheduler = scheduler
        animationView.alpha = Constants.visibleAlpha
    }

    // MARK: - Animate
    public func startAnimation(
        withDuration duration: TimeInterval,
        transition: ShimmerComponents.Transition? = nil
    ) {
        switch transition {
        case let .crossDisolve(transitionDuration):
            UIView.transition(
                with: animationView,
                duration: transitionDuration,
                options: .transitionCrossDissolve
            ) {
                self.animationView.alpha = Constants.visibleAlpha
            } completion: { _ in
                self.animationView.startAnimation(
                    withDuration: duration
                )
            }
        case .none:
            animationView.alpha = Constants.visibleAlpha
            animationView.startAnimation(withDuration: duration)
        }
    }

    public func stopAnimation(
        transition: ShimmerComponents.Transition? = nil
    ) {
        scheduler?.removeListener(self)
        scheduler = nil
        switch transition {
        case let .crossDisolve(transitionDuration):
            UIView.transition(
                with: animationView,
                duration: transitionDuration,
                options: .transitionCrossDissolve
            ) {
                self.animationView.alpha = Constants.invisibleAlpha
            } completion: { _ in
                self.animationView.stopAnimation()
            }
        case .none:
            animationView.alpha = Constants.invisibleAlpha
            animationView.stopAnimation()
        }
    }
}

private extension ShimmerView {
    // MARK: - Setup
    func setup() {
        addSubview(animationView)
        animationView.alpha = Constants.invisibleAlpha
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension ShimmerView: ShimmerViewSchedulerListener {
    public func schedulerFired(_ scheduler: ShimmerViewScheduler) {
        guard self.scheduler === scheduler else {
            return
        }
        animationView.animateOnce(with: Constants.animationDuration)
    }
}

// MARK: - Styles
extension Style where Component: ShimmerView {
    public static var lightShimmerStyle: Style {
        return Style {
            let designEngine = $0.designEngine
            $0.primaryColor = designEngine.colors.backgroundPrimary.uiColor
            $0.secondaryColor = designEngine.colors.backgroundSecondary.uiColor
        }
    }
}
