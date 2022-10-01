//
//  LoginModel.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import Foundation

final class LoginModel: LoginModelProtocol {
    // MARK: - Dependencies
    private let providers: [LoginActionType: LoginProviding?]

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
        return types
            .sorted { $0.priority < $1.priority }
            .map { LoginModelAction(type: $0) }
    }

    func proceedAuthentication(_ type: LoginActionType) async throws -> LoginModelStatus {
        switch type {
        case .signInViaPhoneNumber:
            return .proceedWithCustomAuth
        case .signInViaFacebook, .signInViaAppleID:
            guard let provider = providers[type] else {
                throw "There is now provider for type \(type)".asBaseError()
            }
            return try await withCheckedThrowingContinuation { continuation in
                provider?.authenticate { result in
                    switch result {
                    case .success(let state):
                        switch state.nextStep {
                        case .confirmSignInWithSMSCode, .confirmSignUp:
                            continuation.resume(returning: .confirmationCodeSent)
                        case .done:
                            return continuation.resume(returning: .authentificated)
                        case .resetPassword:
                            return continuation.resume(throwing: "Unsupported authorization state".asBaseError())
                        default:
                            return continuation.resume(throwing: "Unsupported authorization state".asBaseError())
                        }
                    case .failure(let error):
                        return continuation.resume(
                            throwing: error.recoverySuggestion.asBaseError()
                        )
                    }
                }
            }
        }
    }
}
