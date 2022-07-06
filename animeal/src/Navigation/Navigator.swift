import UIKit

protocol Navigating {
    var navigationController: UINavigationController? { get }
    var topViewController: UIViewController? { get }
    var viewControllers: [UIViewController] { get }

    func makeChildNavigator() -> Navigator?
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool, completion: (() -> Void)?)
    func popToRoot(animated: Bool)
}

public final class Navigator: Navigating {

    // MARK: - Dependencies
    private(set) weak var navigationController: UINavigationController?
    private let rootViewControllerIndex: Int

    var topViewController: UIViewController? {
        navigationController?.topViewController?.presentedViewController
            ?? navigationController?.topViewController
            ?? navigationController
    }

    var viewControllers: [UIViewController] {
        let viewControllers = navigationController?.viewControllers ?? []
        guard viewControllers.indices.contains(rootViewControllerIndex) else {
            return []
        }
        return Array(viewControllers.suffix(from: rootViewControllerIndex))
    }

    // MARK: - Initializers
    init(navigationController: UINavigationController, rootViewControllerIndex: Int) {
        self.navigationController = navigationController
        self.rootViewControllerIndex = rootViewControllerIndex
    }

    convenience init(navigationController: UINavigationController) {
        let index = navigationController.viewControllers.count

        self.init(navigationController: navigationController, rootViewControllerIndex: max(0, index))
    }

    convenience init() {
        self.init(navigationController: UINavigationController(), rootViewControllerIndex: 0)
    }

    // MARK: - Child flow creation
    func makeChildNavigator() -> Navigator? {
        guard let navigationController = navigationController else {
            return nil
        }

        return Navigator(navigationController: navigationController)
    }

    // MARK: - Modal presentation
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        navigationController?.present(viewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController?.presentingViewController?.dismiss(animated: animated, completion: completion)
    }

    // MARK: - Push navigation
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let completionClosure = completion else {
            navigationController?.pushViewController(viewController, animated: animated)
            return
        }

        push(viewController, animated: animated, completion: completionClosure)
    }

    func pop(animated: Bool, completion: (() -> Void)?) {
        guard let completionClosure = completion else {
            navigationController?.popViewController(animated: animated)
            return
        }

        pop(animated: animated, completion: completionClosure)
    }

    private func push(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        navigationController?.pushViewController(viewController, animated: animated, completion: completion)
    }

    private func pop(animated: Bool, completion: @escaping () -> Void) {
        navigationController?.popViewController(animated: animated, completion: completion)
    }

    // MARK: - Operations with navigation stack

    /// Pops view controllers until the root view controller is at the top
    /// of the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: `true`, if the transition should be animated, otherwise `false`
    func popToRoot(animated: Bool) {
        guard let navigationController = navigationController else {
            return
        }

        if navigationController.viewControllers.indices ~= rootViewControllerIndex {
            let rootViewController = navigationController.viewControllers[rootViewControllerIndex]
            navigationController.popToViewController(rootViewController, animated: animated)
        } else {
            assertionFailure("""
            Unexpected behavior: Trying to pop to rootController of the flow, but
            Either navigation stack had changed and rootController was already popped from the stack
            Or rootController did not pushed on the stack yet
            """)

            navigationController.popToRootViewController(animated: animated)
        }
    }
}
