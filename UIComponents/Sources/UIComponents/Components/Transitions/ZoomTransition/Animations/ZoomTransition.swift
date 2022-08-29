import UIKit

final class ZoomTransition: TransitionAnimator {

    init(direction: AnimationDirection) {
        super.init(inDuration: 0.22, outDuration: 0.2, direction: direction)
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        switch direction {
        case .in:
            toViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(
                withDuration: 0.6,
                delay: 0.0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [.curveEaseOut],
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.toViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                },
                completion: { _ in
                    transitionContext.completeTransition(true)
                }
            )
        case .out:
            UIView.animate(
                withDuration: outDuration,
                delay: 0.0,
                options: [.curveEaseIn],
                animations: { [weak self] in
                    guard let self = self else { return }
                    self.fromViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    self.fromViewController.view.alpha = 0.0
                },
                completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        }
    }
}
