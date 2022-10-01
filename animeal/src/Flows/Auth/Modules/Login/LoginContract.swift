import UIKit

// MARK: - View
protocol LoginViewable: ErrorDisplayable {
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

protocol LoginViewState: ErrorDisplayCompatible {
    var onOnboardingStepsHaveBeenPrepared: (([LoginViewOnboardingStep]) -> Void)? { get set }
    var onActionsHaveBeenPrepaped: (([LoginViewAction]) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol LoginModelProtocol: AnyObject {
    func fetchOnboardingSteps() -> [LoginModelOnboardingStep]
    func fetchActions() -> [LoginModelAction]
    func proceedAuthentication(_ type: LoginActionType) async throws -> LoginModelStatus
}

// MARK: - Coordinator
// sourcery: AutoMockable
protocol LoginCoordinatable: Coordinatable {
    func moveFromLogin(to route: LoginRoute)
}
