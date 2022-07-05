import UIKit
import Common

final class LoginModuleAssembler: Assembling {
    static func assemble() -> UIViewController {
        let model = LoginModel()
        let viewModel = LoginViewModel(
            model: model,
            actionsMapper: LoginViewActionMapper(),
            onboardingMapper: LoginViewOnboardingStepsMapper()
        )
        let view = LoginViewController(viewModel: viewModel)

        viewModel.onOnboardingStepsHaveBeenPrepared = { [weak view] viewSteps in
            view?.applyOnboarding(viewSteps)
        }
        viewModel.onActionsHaveBeenPrepaped = { [weak view] viewActions in
            view?.applyActions(viewActions)
        }

        viewModel.setup()

        return view
    }
}
