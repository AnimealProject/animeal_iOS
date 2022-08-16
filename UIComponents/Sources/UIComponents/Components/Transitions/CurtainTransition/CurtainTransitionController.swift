import UIKit


/// CurtainTransitionController provides curtain like transition between view controllers.
/// After `iOS 16` could be replased with `UISheetPresentationController`
///
/// Usage example:
///
///     let child = ChildViewController()
///     child.transitioningDelegate = transition
///     child.modalPresentationStyle = .custom
///
///     paarent.present(child, animated: true)
///
///
@available(swift, deprecated: 16.0, message: "Use UISheetPresentationController instead")
public final class CurtainTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    private let driver = TransitionDriver()
    private var detent: TransitionDetent

    public init(detent: TransitionDetent) {
        self.detent = detent
        super.init()
    }

    // MARK: - Presentation controller
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        driver.link(to: presented)
        let presentationController = DimmPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
        presentationController.driver = driver
        presentationController.detent = detent
        return presentationController
    }

    // MARK: - Animation
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation()
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimation()
    }

    // MARK: - Interaction
    public func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return driver
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return driver
    }
}
