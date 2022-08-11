import UIKit

// MARK: - View
protocol LoginViewable: AnyObject {
    func applyOnboarding(_ onboardingSteps: [LoginViewOnboardingStep])
    func applyActions(_ actions: [LoginViewAction])
}

// MARK: - ViewModel
typealias LoginViewModelProtocol = LoginViewModelLifeCycle
    & LoginViewInteraction
    & LoginViewState

protocol LoginViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol LoginViewInteraction: AnyObject {
    func handleActionEvent(_ event: LoginViewActionEvent)
}

protocol LoginViewState: AnyObject {
    var onOnboardingStepsHaveBeenPrepared: (([LoginViewOnboardingStep]) -> Void)? { get set }
    var onActionsHaveBeenPrepaped: (([LoginViewAction]) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol LoginModelProtocol: AnyObject {
    var proceedAuthentificationResponse: ((LoginModelStatus) -> Void)? { get set }

    func fetchOnboardingSteps() -> [LoginModelOnboardingStep]
    func fetchActions() -> [LoginModelAction]
    func proceedAuthentication(_ type: LoginActionType)
}

// MARK: - Coordinator
protocol LoginCoordinatable: Coordinatable {
    func move(_ route: LoginRoute)
}
