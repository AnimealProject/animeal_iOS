import UIKit

public extension UITextField {
    func setPadding(_ interval: CGFloat = 18.0) {
        setLeftPadding(interval)
        setRightPadding(interval)
    }

    func setLeftPadding(_ interval: CGFloat = 18.0) {
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: interval,
                height: self.frame.size.height
            )
        )
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPadding(_ interval: CGFloat = 18.0) {
        let paddingView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: interval,
                height: self.frame.size.height
            )
        )
        self.rightView = paddingView
        self.rightViewMode = .always
    }

    func setLeftPaddingView(_ paddingView: UIView) {
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingView(_ paddingView: UIView) {
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

public extension UINavigationController {
    func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        pushViewController(viewController, animated: animated)

        guard
            animated,
            let coordinator = transitionCoordinator
        else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }

    func popViewController(
        animated: Bool,
        completion: @escaping () -> Void
    ) {
        popViewController(animated: animated)

        guard
            animated,
            let coordinator = transitionCoordinator
        else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
