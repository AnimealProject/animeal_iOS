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
        navigator.present(loginViewController, animated: true, completion: nil)
    }

    func stop() {
        navigator.dismiss(animated: true, completion: nil)
    }

    // MARK: - Routing
    func move(_ route: LoginRoute) {
        switch route {
        case .customAuthentication:
            break
        case .codeConfirmation:
            break
        case .profileFilling:
            break
        }
    }
}
