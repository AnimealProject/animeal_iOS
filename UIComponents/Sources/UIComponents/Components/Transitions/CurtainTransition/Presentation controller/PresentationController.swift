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
        case .selfSizable:
            return calculateRectBasedOnContent(bounds)
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

private extension PresentationController {
    private enum Constants {
        static let maxPermanentTopOffset: CGFloat = 50.0
    }

    func calculateRectBasedOnContent(_ bounds: CGRect) -> CGRect {
        guard let presentedView = presentedView else { return .zero }
        presentedView.setNeedsLayout()
        presentedView.layoutIfNeeded()
        if let scrollView = presentedView.subviews
            .first(where: { $0 is UIScrollView }) as? UIScrollView {
            if presentedView.subviews.count > 1 {
                return calculateRectReferencedFromScrollAndPresentedViews(
                    scrollView,
                    presentedView,
                    basedOn: bounds
                )
            } else {
                return calculateRectIfThereIsScrollView(
                    scrollView,
                    basedOn: bounds
                )
            }
        } else {
            return calculateRectReferencedFromPresentedView(
                presentedView,
                basedOn: bounds
            )
        }
    }

    func calculateRectIfThereIsScrollView(
        _ scrollView: UIScrollView,
        basedOn bounds: CGRect
    ) -> CGRect {
        let maxHeight = max(
            scrollView.contentSize.height,
            bounds.height - Constants.maxPermanentTopOffset
        )
        let size = CGSize(width: bounds.width, height: maxHeight)
        let origin = CGPoint(x: 0, y: bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }

    func calculateRectReferencedFromPresentedView(
        _ presentedView: UIView,
        basedOn bounds: CGRect
    ) -> CGRect {
        let targetSize = CGSize(
            width: bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let actualSize = presentedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: UILayoutPriority.required,
            verticalFittingPriority: UILayoutPriority.fittingSizeLevel
        )
        let maxHeight = max(
            actualSize.height,
            bounds.height - Constants.maxPermanentTopOffset
        )
        let size = CGSize(width: bounds.width, height: maxHeight)
        let origin = CGPoint(x: 0.0, y: bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }

    func calculateRectReferencedFromScrollAndPresentedViews(
        _ scrollView: UIScrollView,
        _ presentedView: UIView,
        basedOn bounds: CGRect
    ) -> CGRect {
        let otherContentSize = calculateRectReferencedFromPresentedView(
            presentedView,
            basedOn: bounds
        ).size
        let scrollViewSize = CGSize(
            width: bounds.width,
            height: scrollView.contentSize.height
        )
        let maxHeight = max(
            scrollViewSize.height + otherContentSize.height,
            bounds.height - Constants.maxPermanentTopOffset
        )
        let size = CGSize(width: bounds.width, height: maxHeight)
        let origin = CGPoint(x: 0, y: bounds.height - size.height)
        return CGRect(origin: origin, size: size)
    }
}
