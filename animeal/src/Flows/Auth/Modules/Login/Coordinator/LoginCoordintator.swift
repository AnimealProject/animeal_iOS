import Foundation
import UIKit

final class LoginCoordinator: LoginCoordinatable {
    // MARK: - Dependencies
    private let navigator: Navigating
    private let completion: (() -> Void)?

    // MARK: - Accessible properties
    private lazy var presentingWindow: UIWindow = {
        let item = UIWindow()
        item.makeKeyAndVisible()
        return item
    }()

    // MARK: - Initializers
    init(
        navigator: Navigating,
        completion: (() -> Void)?
    ) {
        self.navigator = navigator
        self.completion = completion
    }

    // MARK: - Instance Methods
    func start() {
        let loginViewController = LoginModuleAssembler(
            coordinator: self,
            window: presentingWindow
        ).assemble()
        loginViewController.modalPresentationStyle = .overCurrentContext
        navigator.push(loginViewController, animated: true, completion: nil)
    }

    func stop() {
        navigator.pop(animated: true, completion: nil)
    }

    // MARK: - Routing
    func moveFromLogin(to route: LoginRoute) {
        switch route {
        case .customAuthentication:
            guard let childNavigator = navigator.makeChildNavigator() else { return }
            let phoneAuthCoordinator = PhoneAuthCoordinator(navigator: childNavigator, completion: nil)
            phoneAuthCoordinator.start()
        case .codeConfirmation:
            break
        case .done:
            break
        }
    }
}
