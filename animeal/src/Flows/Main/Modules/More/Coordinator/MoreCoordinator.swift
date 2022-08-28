import Foundation

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
        switch route {
        case .profilePage:
            let profile = ProfileModuleAssembler.assemble()
            navigator.navigationController?.customTabBarController?.setTabBarHidden(true, animated: true)
            navigator.navigationController?.setNavigationBarHidden(false, animated: false)
            navigator.push(profile, animated: true, completion: nil)
        case .donate:
            break
        case .help:
            break
        case .about:
            break
        case .account:
            break
        }
    }
}
