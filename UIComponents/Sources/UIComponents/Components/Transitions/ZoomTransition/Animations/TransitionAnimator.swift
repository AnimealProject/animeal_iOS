import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var toViewController: UIViewController!
    var fromViewController: UIViewController!
    let inDuration: TimeInterval
    let outDuration: TimeInterval
    let direction: AnimationDirection

    init(inDuration: TimeInterval, outDuration: TimeInterval, direction: AnimationDirection) {
        self.inDuration = inDuration
        self.outDuration = outDuration
        self.direction = direction
        super.init()
    }

    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return direction == .in ? inDuration : outDuration
    }

    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch direction {
        case .in:
            guard let toViewController = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.to
            ), let fromViewController = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.from
            ) else { return }

            self.toViewController = toViewController
            self.fromViewController = fromViewController

            let container = transitionContext.containerView
            container.addSubview(toViewController.view)
        case .out:
            guard let toViewController = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.to
            ), let fromViewController = transitionContext.viewController(
                forKey: UITransitionContextViewControllerKey.from
            ) else { return }

            self.toViewController = toViewController
            self.fromViewController = fromViewController
        }
    }
}
