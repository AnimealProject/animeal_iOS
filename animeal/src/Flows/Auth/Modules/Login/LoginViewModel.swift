//
//  LoginViewModel.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import Foundation
import Services

final class LoginViewModel: LoginViewModelLifeCycle, LoginViewInteraction, LoginViewState {
    // MARK: - Private properties
    private var viewActions: [LoginViewAction]

    // MARK: - Dependencies
    private let model: LoginModelProtocol
    private let coordinator: LoginCoordinatable
    private let actionsMapper: LoginViewActionMappable
    private let onboardingMapper: LoginViewOnboardingStepsMappable

    // MARK: - State
    var onOnboardingStepsHaveBeenPrepared: (([LoginViewOnboardingStep]) -> Void)?
    var onActionsHaveBeenPrepaped: (([LoginViewAction]) -> Void)?
    var onErrorIsNeededToDisplay: ((String) -> Void)?

    // MARK: - Initialization
    init(
        model: LoginModelProtocol,
        coordinator: LoginCoordinatable,
        actionsMapper: LoginViewActionMappable,
        onboardingMapper: LoginViewOnboardingStepsMappable
    ) {
        self.model = model
        self.coordinator = coordinator
        self.actionsMapper = actionsMapper
        self.onboardingMapper = onboardingMapper
        self.viewActions = []
        setup()
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        let modelOnboardingSteps = model.fetchOnboardingSteps()
        let modelActions = model.fetchActions()

        let viewOnboardingsStep = onboardingMapper.mapSteps(modelOnboardingSteps)
        let viewActions = actionsMapper.mapActions(modelActions)

        onOnboardingStepsHaveBeenPrepared?(viewOnboardingsStep)
        onActionsHaveBeenPrepaped?(viewActions)
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: LoginViewActionEvent) {
        switch event {
        case .tapInside(let identifier):
            let modelActions = model.fetchActions()
            let modelAction = modelActions.first(where: { $0.identifier == identifier })
            guard let modelAction else { return }
            proceedWithAuthentication(with: modelAction.type)
        }
    }

    private func proceedWithAuthentication(with type: LoginActionType) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.proceedAuthentication(type)
                switch result {
                case .proceedWithCustomAuth:
                    coordinator.moveFromLogin(to: LoginRoute.customAuthentication)
                case .confirmationCodeSent:
                    coordinator.moveFromLogin(to: LoginRoute.codeConfirmation)
                case .authentificated:
                    coordinator.moveFromLogin(to: LoginRoute.done)
                }
            } catch {
                onErrorIsNeededToDisplay?(error.localizedDescription)
            }
        }
    }
}
