import UIKit

class PresentationController: UIPresentationController {
    var driver: TransitionDriver!
    var detent: TransitionDetent!

    // MARK: - Override
    override var shouldPresentInFullscreen: Bool {
        return false
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        let bounds = containerView.bounds
        switch detent {
        case .custom(let customHeight):
            return CGRect(
                x: 0,
                y: bounds.height - customHeight,
                width: bounds.width,
                height: customHeight
            )
        case .medium:
            let halfHeight = bounds.height / 2
            return CGRect(
                x: 0,
                y: halfHeight,
                width: bounds.width,
                height: halfHeight
            )

        case .large:
            let height = bounds.height - 50
            return CGRect(
                x: 0,
                y: 50,
                width: bounds.width,
                height: height
            )
        case .none:
            return .zero
        }
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let presentedView = presentedView else {
            return
        }
        driver.direction = .present
        containerView?.addSubview(presentedView)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        if completed {
            driver.direction = .dismiss
        }
    }
}
