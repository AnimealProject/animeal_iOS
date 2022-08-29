import UIKit

final class BlurryPresentationController: UIPresentationController {
    private lazy var overlay: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView()
        blurEffectView.backgroundColor = .clear
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    private var blurAnimator: UIViewPropertyAnimator?

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        blurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [overlay] in
            overlay.effect = UIBlurEffect(style: .dark)
        }
        blurAnimator?.fractionComplete = 0.15 // set the blur intensity.

        overlay.frame = containerView.bounds
        containerView.insertSubview(overlay, at: 0)

        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] _ in
                self?.overlay.alpha = 1.0
            },
            completion: nil
        )
    }

    override func dismissalTransitionWillBegin() {
        blurAnimator?.stopAnimation(true)
        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] _ in
                self?.overlay.alpha = 0.0
            },
            completion: nil
        )
    }
}
