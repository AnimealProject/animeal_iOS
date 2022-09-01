import Foundation
import UIKit

final class MoreCoordinator: Coordinatable {
    // MARK: - Private properties
    private var navigator: Navigating

    // MARK: - Dependencies
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
}

extension MoreCoordinator: MoreCoordinatable {
    func moveFromLogin(to route: MoreRoute) {
        var viewController: UIViewController
        switch route {
        case .profilePage:
            viewController = ProfileModuleAssembler.assemble()
        case .donate:
            viewController = MorePartitionModuleAssembler.assemble(.donate)
        case .help:
            viewController = MorePartitionModuleAssembler.assemble(.help)
        case .about:
            viewController = MorePartitionModuleAssembler.assemble(.about)
        case .account:
            viewController = MorePartitionModuleAssembler.assemble(.account)
        }
        navigator.navigationController?.customTabBarController?.setTabBarHidden(true, animated: true)
        navigator.navigationController?.setNavigationBarHidden(false, animated: false)
        navigator.push(viewController, animated: true, completion: nil)
    }
}
