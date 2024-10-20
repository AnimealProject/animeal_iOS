import UIKit

// swiftlint:disable all
final class TransitionDriver: UIPercentDrivenInteractiveTransition {
    private weak var presentedController: UIViewController?
    private var panRecognizer: UIPanGestureRecognizer?
    
    private var cancelledOtherGestureRecognizers = NSHashTable<UIGestureRecognizer>(
        options: [.weakMemory, .objectPointerPersonality]
    )

    // MARK: - Direction
    var direction: TransitionDirection = .present

    // MARK: - Linking
    func link(to controller: UIViewController) {
        presentedController = controller

        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(recognizer:)))
        panRecognizer?.delegate = self
        presentedController?.view.addGestureRecognizer(panRecognizer!)
    }

    // MARK: - Override
    override var wantsInteractiveStart: Bool {
        get {
            switch direction {
            case .present:
                return false
            case .dismiss:
                let gestureIsActive = panRecognizer?.state == .began
                return gestureIsActive
            }
        }

        set { }
    }

    @objc private func handle(recognizer r: UIPanGestureRecognizer) {
        switch direction {
        case .present:
            handlePresentation(recognizer: r)
        case .dismiss:
            handleDismiss(recognizer: r)
        }
        handleCancelledGestureRecognersState(recognizer: r)
    }
}

// MARK: - Gesture Handling
private extension TransitionDriver {

    func handlePresentation(recognizer r: UIPanGestureRecognizer) {
        switch r.state {
        case .began:
            pause()
        case .changed:
            let increment = -r.incrementToBottom(maxTranslation: maxTranslation)
            update(percentComplete + increment)

        case .ended, .cancelled:
            if r.isProjectedToDownHalf(maxTranslation: maxTranslation) {
                cancel()
            } else {
                finish()
            }

        case .failed:
            cancel()

        default:
            break
        }
    }

    func handleDismiss(recognizer r: UIPanGestureRecognizer) {
        switch r.state {
        case .began:
            pause() // Pause allows to detect isRunning

            if !isRunning {
                presentedController?.dismiss(animated: true) // Start the new one
            }

        case .changed:
            update(percentComplete + r.incrementToBottom(maxTranslation: maxTranslation))

        case .ended, .cancelled:
            if r.isProjectedToDownHalf(maxTranslation: maxTranslation) {
                finish()
            } else {
                cancel()
            }

        case .failed:
            cancel()

        default:
            break
        }
    }
    
    func handleCancelledGestureRecognersState(recognizer r: UIPanGestureRecognizer) {
        switch r.state {
        case .began, .changed:
            break
        default:
            cancelledOtherGestureRecognizers.allObjects
                .forEach { $0.isEnabled = true }
        }
    }

    var maxTranslation: CGFloat {
        return presentedController?.view.frame.height ?? 0
    }

    /// `pause()` before call `isRunning`
    var isRunning: Bool {
        return percentComplete != 0
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TransitionDriver: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        let scrollViewContainableRepresentation = "scrollView"
        let selector = Selector(stringLiteral: scrollViewContainableRepresentation)
        guard
            let container = presentedController?.view,
            let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
            otherGestureRecognizer is UIPanGestureRecognizer,
            otherGestureRecognizer.responds(to: selector),
            let otherScrollView = otherGestureRecognizer.perform(selector).takeUnretainedValue() as? UIScrollView
        else { return true }
        
        let velocity = panGestureRecognizer.velocity(in: container).y
        guard velocity != 0.0 else { return false }
        let isGestureDown = velocity > 0.0
        
        let isEdgePanGestureDown = isGestureDown && otherScrollView.contentOffset.y <= 0.0
        let isEdgePanGestureUp = !isGestureDown &&
            (otherScrollView.contentOffset.y + otherScrollView.bounds.size.height) >= otherScrollView.contentSize.height
        
        if isEdgePanGestureDown || isEdgePanGestureUp {
            otherGestureRecognizer.isEnabled = false
            cancelledOtherGestureRecognizers.add(otherGestureRecognizer)
            return true
        } else {
            return false
        }
    }
}

private extension UIPanGestureRecognizer {
    func isProjectedToDownHalf(maxTranslation: CGFloat) -> Bool {
        let endLocation = projectedLocation(decelerationRate: .fast)
        let isPresentationCompleted = endLocation.y > maxTranslation / 2

        return isPresentationCompleted
    }

    func incrementToBottom(maxTranslation: CGFloat) -> CGFloat {
        let translation = self.translation(in: view).y
        setTranslation(.zero, in: nil)

        let percentIncrement = translation / maxTranslation
        return percentIncrement
    }
}
// swiftlint:enable all
