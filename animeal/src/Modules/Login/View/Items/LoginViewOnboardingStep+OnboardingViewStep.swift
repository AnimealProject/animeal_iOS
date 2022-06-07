//
//  LoginViewOnboardingStep+OnboardingViewStep.swift
//  animeal
//
//  Created by Диана Тынкован on 3.06.22.
//

// System
import UIKit

// SDK
import UIComponents

extension LoginViewOnboardingStep {
    var onboardingViewStepModel: OnboardingView.Step {
        return OnboardingView.Step(
            identifier: identifier,
            image: UIImage(named: associatedIcon),
            title: title,
            text: text
        )
    }
}
