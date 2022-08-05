//
//  LoginModel.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import Foundation

final class LoginModel: LoginModelProtocol {
    // MARK: - Private properties

    // MARK: - Dependencies
    private let providers: [LoginActionType: LoginProviding?]

    // MARK: - Responses
    var proceedAuthentificationResponse: ((LoginModelStatus) -> Void)?

    // MARK: - Initialization
    init(providers: [LoginActionType: LoginProviding?]) {
        self.providers = providers
    }

    // MARK: - Requests
    func fetchOnboardingSteps() -> [LoginModelOnboardingStep] {
        return [
            LoginModelOnboardingStep(
                identifier: UUID().uuidString,
                title: "Take care of pets",
                text: "Some of them are homeless, they need your help"
            ),
            LoginModelOnboardingStep(
                identifier: UUID().uuidString,
                title: "Take care of pets",
                text: "Some of them are homeless, they need your help"
            ),
            LoginModelOnboardingStep(
                identifier: UUID().uuidString,
                title: "Take care of pets",
                text: "Some of them are homeless, they need your help"
            ),
            LoginModelOnboardingStep(
                identifier: UUID().uuidString,
                title: "Take care of pets",
                text: "Some of them are homeless, they need your help"
            )
        ]
    }

    func fetchActions() -> [LoginModelAction] {
        let types = Array(providers.keys)
        return types.map { LoginModelAction(type: $0) }
    }

    func proceedAuthentication(_ type: LoginActionType) {
        switch type {
        case .signInViaPhoneNumber:
            return
        case .signInViaFacebook, .signInViaAppleID:
            guard let provider = providers[type] else { return }
            provider?.authenticate { [weak self] result in
                switch result {
                case .success(let state):
                    switch state.nextStep {
                    case .confirmSignInWithSMSCode, .confirmSignUp:
                        self?.proceedAuthentificationResponse?(.confirmationCodeSent)
                    case .done:
                        self?.proceedAuthentificationResponse?(.authentificated)
                    case .resetPassword:
                        self?.proceedAuthentificationResponse?(.resetPassword)
                    default:
                        return
                    }
                case .failure(let error):
                    self?.proceedAuthentificationResponse?(
                        .failure(error.errorDescription.description)
                    )
                }
            }
        }
    }
}
