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
                title: title
            )
            let buttonView = buttonsFactory.makeSignInWithAppleButton()
            buttonView.condifure(model)
            return buttonView
        case .signInViaFacebook:
            let model = ButtonView.Model(
                identifier: identifier,
                viewType: ButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title
            )
            let buttonView = buttonsFactory.makeSignInWithFacebookButton()
            buttonView.condifure(model)
            return buttonView
        case .signInViaAppleID:
            let model = ButtonView.Model(
                identifier: identifier,
                viewType: ButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title
            )
            let buttonView = buttonsFactory.makeSignInWithMobileButton()
            buttonView.condifure(model)
            return buttonView
        }
    }
}
