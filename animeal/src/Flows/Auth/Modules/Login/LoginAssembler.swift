import UIKit
import Common

@MainActor
final class LoginModuleAssembler {
    private let coordinator: LoginCoordinatable
    private let window: UIWindow

    init(coordinator: LoginCoordinatable, window: UIWindow) {
        self.coordinator = coordinator
        self.window = window
    }

    func assemble() -> UIViewController {
        let model = LoginModel(
            providers: [
                LoginActionType.signInViaPhoneNumber: nil,
                LoginActionType.signInViaFacebook: FacebookLoginProvider(
                    presentationAnchor: window,
                    authenticationService: AppDelegate.shared.context.authenticationService
                ),
                LoginActionType.signInViaAppleID: AppleLoginProvider(
                    presentationAnchor: window,
                    authenticationService: AppDelegate.shared.context.authenticationService
                )
            ]
        )
        let viewModel = LoginViewModel(
            model: model,
            coordinator: coordinator,
            actionsMapper: LoginViewActionMapper(),
            onboardingMapper: LoginViewOnboardingStepsMapper()
        )
        let view = LoginViewController(viewModel: viewModel)

        return view
    }
}
