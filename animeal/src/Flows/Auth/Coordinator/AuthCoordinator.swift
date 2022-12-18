import UIKit
import Services
import UIComponents
import Amplify

@MainActor
final class AuthCoordinator: Coordinatable, AlertCoordinatable {
    typealias Context = UserProfileServiceHolder

    // MARK: - Private properties
    private let _navigator: Navigating
    private let context: Context

    // MARK: - Dependencies
    private let presentingWindow: UIWindow
    private let completion: (() -> Void)?

    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        presentingWindow: UIWindow,
        context: Context = AppDelegate.shared.context,
        completion: (() -> Void)?
    ) {
        self.presentingWindow = presentingWindow
        self.context = context
        self.completion = completion
        let navigationController = UINavigationController()
        self._navigator = Navigator(navigationController: navigationController)
        self.presentingWindow.rootViewController = navigationController
    }

    // MARK: - Life cycle
    func start() {
        switch context.profileService.getCurrentUserValidationModel().isSignedIn {
        case true:
            let validationModel = context.profileService.getCurrentUserValidationModel()
            validateUser(
                isPhoneNumberVerified: validationModel.phoneNumberVerified,
                isEmailVerified: validationModel.emailVerified
            )
            presentingWindow.makeKeyAndVisible()
        case false:
            let loginViewController = LoginModuleAssembler(
                coordinator: self,
                window: presentingWindow
            ).assemble()
            _navigator.push(loginViewController, animated: false, completion: nil)
            presentingWindow.makeKeyAndVisible()
        }
    }

    func stop() {
        presentingWindow.resignKey()
        completion?()
    }

    private func validateUser(isPhoneNumberVerified: Bool, isEmailVerified: Bool) {
        switch (isPhoneNumberVerified, isEmailVerified) {
        case (false, _):
            let viewController = ProfileAfterSocialAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: false, completion: nil)
        case (_, false):
            let viewController = ProfileAfterCustomAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: false, completion: nil)
        default:
            logError("[APP] should not be here")
        }
    }
}

extension AuthCoordinator: LoginCoordinatable {
    func moveFromLogin(to route: LoginRoute) {
        switch route {
        case .customAuthentication:
            let viewController = CustomAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: true, completion: nil)
        case .codeConfirmation:
            break
        case .done:
            let viewController = ProfileAfterSocialAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: true, completion: nil)
        }
    }
}

extension AuthCoordinator: CustomAuthCoordinatable {
    func moveFromCustomAuth(to route: CustomAuthRoute) {
        switch route {
        case .codeConfirmation(let details):
            let viewController = VerificationAfterCustomAuthAssembler.assembly(
                coordinator: self,
                deliveryDestination: details.destination
            )
            _navigator.push(viewController, animated: true, completion: nil)
        case .setNewPassword:
            break
        case .resetPassword:
            break
        case .done:
            let viewController = ProfileAfterCustomAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: true, completion: nil)
        case let .picker(make):
            guard let viewController = make() else { return }
            _navigator.present(viewController, animated: false, completion: nil)
        case .dismiss:
            if let bottomSheetVC = _navigator.topViewController as? BottomSheetPresentationController {
                bottomSheetVC.dismissView(completion: nil)
            }
        }
    }
}

extension AuthCoordinator: VerificationCoordinatable {
    func moveFromVerification(to route: VerificationRoute) {
        switch route {
        case .fillProfile:
            let viewController = ProfileAfterCustomAuthAssembler.assembly(coordinator: self)
            _navigator.push(viewController, animated: true, completion: nil)
        }
    }
}

extension AuthCoordinator: ProfileCoordinatable {
    func move(to route: ProfileRoute) {
        switch route {
        case .done:
            stop()
        case .cancel:
            _navigator.popToRoot(animated: true)
        case let .confirm(details, attribute):
            let viewController = VerificationAfterProfileAuthAssembler.assembly(
                coordinator: self,
                deliveryDestination: details.destination,
                attribute: VerificationModelAttribute(
                    key: VerificationModelAttributeKey(userAttributeKey: attribute.key),
                    value: attribute.value
                )
            )
            _navigator.push(viewController, animated: true, completion: nil)
        case .picker(let make):
            guard let viewController = make() else { return }
            _navigator.present(viewController, animated: false, completion: nil)
        case .dismiss:
            if let bottomSheetVC = _navigator.topViewController as? BottomSheetPresentationController {
                bottomSheetVC.dismissView(completion: nil)
            }
        }
    }
}
