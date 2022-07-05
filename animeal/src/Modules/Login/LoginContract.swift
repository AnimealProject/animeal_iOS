//
//  LoginContract.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import UIKit

// MARK: - View
protocol LoginViewModelOutput: AnyObject {
    func applyOnboarding(_ onboardingSteps: [LoginViewOnboardingStep])
    func applyActions(_ actions: [LoginViewAction])
}

// MARK: - ViewModel
typealias LoginCombinedViewModel = LoginViewModelLifeCycle
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
    func fetchOnboardingSteps() -> [LoginModelOnboardingStep]
    func fetchActions() -> [LoginModelAction]
}
