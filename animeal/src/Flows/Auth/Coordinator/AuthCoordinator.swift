import UIKit

final class AuthCoordinator: Coordinatable {
    // MARK: - Private properties
    private let navigator: Navigating

    // MARK: - Dependencies
    private let presentingWindow: UIWindow
    private let completion: (() -> Void)?

    // MARK: - Initialization
    init(
        presentingWindow: UIWindow,
        completion: (() -> Void)?
    ) {
        self.presentingWindow = presentingWindow
        self.completion = completion
        let navigationController = UINavigationController()
        self.navigator = Navigator(navigationController: navigationController)
        self.presentingWindow.rootViewController = navigationController
    }

    // MARK: - Life cycle
    func start() {
        let loginViewController = LoginModuleAssembler(
            coordinator: self,
            window: presentingWindow
        ).assemble()
        navigator.push(loginViewController, animated: false, completion: nil)
        presentingWindow.makeKeyAndVisible()
    }

    func stop() {
        presentingWindow.resignKey()
        completion?()
    }
}

extension AuthCoordinator: LoginCoordinatable {
    func moveFromLogin(to route: LoginRoute) {
        switch route {
        case .customAuthentication:
            let viewController = PhoneAuthAssembler.assembly(coordinator: self)
            navigator.push(viewController, animated: true, completion: nil)
        case .codeConfirmation:
            break
        case .done:
            stop()
        }
    }
}

extension AuthCoordinator: PhoneAuthCoordinatable {
    func moveFromPhoneAuth(to route: PhoneAuthRoute) {
        switch route {
        case .codeConfirmation:
            break
        case .setNewPassword:
            break
        case .resetPassword:
            break
        case .done:
            break
        }
    }
}
