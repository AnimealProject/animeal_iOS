import UIKit

final class ZoomTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = BlurryPresentationController(
            presentedViewController: presented,
            presenting: source
        )
        return presentationController
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return ZoomTransition(direction: .in)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return ZoomTransition(direction: .out)
    }
}

enum AnimationDirection {
    case `in` // swiftlint:disable:this identifier_name
    case out
}
