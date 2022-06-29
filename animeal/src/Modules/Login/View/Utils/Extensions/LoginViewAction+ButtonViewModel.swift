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
    var buttonViewModel: ButtonViewModel {
        switch type {
        case .signInViaPhoneNumber:
            return ButtonViewModel(
                identifier: identifier,
                viewType: SignInWithMobileButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title
            )
        case .signInViaFacebook:
            return ButtonViewModel(
                identifier: identifier,
                viewType: SignInWithFacebookButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title
            )
        case .signInViaAppleID:
            return ButtonViewModel(
                identifier: identifier,
                viewType: SignInWithAppleButtonView.self,
                icon: ImageAsset.Image(named: associatedIcon),
                title: title
            )
        }
    }
}
