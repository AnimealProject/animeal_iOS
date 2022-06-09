//
//  LoginViewOnboardingStepsMapper.swift
//  animeal
//
//  Created by Диана Тынкован on 3.06.22.
//

import Foundation

// sourcery: AutoMockable
protocol LoginViewOnboardingStepsMappable {
    func mapStep(_ input: LoginModelOnboardingStep) -> LoginViewOnboardingStep
    func mapSteps(_ input: [LoginModelOnboardingStep]) -> [LoginViewOnboardingStep]
}

final class LoginViewOnboardingStepsMapper: LoginViewOnboardingStepsMappable {
    func mapStep(_ input: LoginModelOnboardingStep) -> LoginViewOnboardingStep {
        let viewOnboardingStep = LoginViewOnboardingStep(
            identifier: input.identifier,
            associatedIcon: mapAssociatedIcon(input),
            title: input.title,
            text: input.text
        )
        return viewOnboardingStep
    }

    func mapSteps(_ input: [LoginModelOnboardingStep]) -> [LoginViewOnboardingStep] {
        let viewOnboardingSteps = input.map(mapStep)
        return viewOnboardingSteps
    }

    private func mapAssociatedIcon(_ input: LoginModelOnboardingStep) -> String {
        return Asset.Images.onboardingFeed.name
    }
}
