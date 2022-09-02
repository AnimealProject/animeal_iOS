import Foundation
import UIKit
import UIComponents

final class MoreCoordinator: Coordinatable {
    // MARK: - Dependencies
    private var navigator: Navigating
    private let completion: (() -> Void)?

    // MARK: - Initialization
    init(
        navigator: Navigator,
        completion: (() -> Void)? = nil
    ) {
        self.navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let moreViewController = MoreModuleAssembler(coordinator: self).assemble()
        navigator.push(moreViewController, animated: false, completion: nil)
    }

    func stop() {
        completion?()
    }

    private func presentError(_ error: String) {
        let alertViewController = AlertViewController(title: error)
        alertViewController.addAction(
            AlertAction(title: "OK", style: .accent) {
                alertViewController.dismiss(animated: true)
            }
        )
        DispatchQueue.main.async {
            self.navigator.present(
                alertViewController,
                animated: true,
                completion: nil
            )
        }
    }
}

extension MoreCoordinator: MoreCoordinatable {
    func routeTo(_ route: MoreRoute) {
        var viewController: UIViewController
        switch route {
        case .profilePage:
            viewController = ProfileModuleAssembler.assemble()
        case .donate:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.donate)
        case .help:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.help)
        case .about:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.about)
        case .account:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.account)
        }
        navigator.navigationController?.customTabBarController?.setTabBarHidden(true, animated: true)
        navigator.navigationController?.setNavigationBarHidden(false, animated: false)
        navigator.push(viewController, animated: true, completion: nil)
    }
}

extension MoreCoordinator: MorePartitionCoordinatable {
    func routeTo(_ route: MorePartitionRoute) {
        switch route {
        case .logout:
            stop()
        case .back:
            navigator.pop(animated: true, completion: nil)
        case .error(let errorDescription):
            presentError(errorDescription)
        }
    }
}
