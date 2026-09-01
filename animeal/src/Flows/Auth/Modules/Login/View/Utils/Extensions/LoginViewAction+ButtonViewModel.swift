//
//  LoginViewAction+ButtonViewModel.swift
//  animeal
//
//  Created by Диана Тынкован on 3.06.22.
//

// System
import UIKit

// SDK
import UIComponents
import Style

extension LoginViewAction {
    var buttonView: ButtonView {
        let buttonsFactory = ButtonViewFactory()
        switch type {
        case .signInViaPhoneNumber:
            let model = ButtonView.Model(
                identifier: identifier,
                viewType: ButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title,
                accessibilityIdentifier: AccessibilityID.Auth.Login.signInWithPhone
            )
            let buttonView = buttonsFactory.makeSignInWithMobileButton()
            buttonView.configure(model)
            return buttonView
        case .signInViaAppleID:
            let model = ButtonView.Model(
                identifier: identifier,
                viewType: ButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title,
                accessibilityIdentifier: AccessibilityID.Auth.Login.signInWithApple
            )
            let buttonView = buttonsFactory.makeSignInWithAppleButton()
            buttonView.configure(model)
            return buttonView
        case .signInAsGuest:
            let model = ButtonView.Model(
                identifier: identifier,
                viewType: ButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title,
                accessibilityIdentifier: AccessibilityID.Auth.Login.continueAsGuest
            )
            let buttonView = buttonsFactory.makeSignInWithGuestButton()
            buttonView.configure(model)
            return buttonView
        }
    }
}
