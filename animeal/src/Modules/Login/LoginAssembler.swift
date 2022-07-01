//
//  LoginAssembler.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import UIKit

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
