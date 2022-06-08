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
import Style

extension LoginViewOnboardingStep {
    var onboardingViewStepModel: OnboardingView.Step {
        return OnboardingView.Step(
            identifier: identifier,
            image: ImageAsset.Image(named: associatedIcon),
            title: title,
            text: text
        )
    }
}
