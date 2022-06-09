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

    // MARK: - Responses

    // MARK: - Initialization
    init() { }

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
        return [
            LoginModelAction(type: LoginActionType.signInViaPhoneNumber),
            LoginModelAction(type: LoginActionType.signInViaFacebook),
            LoginModelAction(type: LoginActionType.signInViaAppleID)
        ]
    }
}
