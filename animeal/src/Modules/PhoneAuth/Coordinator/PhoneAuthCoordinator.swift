import Foundation

final class PhoneAuthCoordinator: PhoneAuthCoordinatable {
    // MARK: - Dependencies
    private let navigator: Navigating
    private let completion: (() -> Void)?

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
        let viewController = PhoneAuthAssembler.assembly(coordinator: self)
        navigator.push(viewController, animated: true, completion: nil)
    }

    func stop() {
        navigator.pop(animated: true, completion: nil)
    }

    // MARK: - Routing
    func move(_ route: PhoneAuthRoute) {
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
