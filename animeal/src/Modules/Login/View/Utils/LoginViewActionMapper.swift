//
//  LoginViewActionMapper.swift
//  animeal
//
//  Created by Диана Тынкован on 3.06.22.
//

import Foundation
import Style

protocol LoginViewActionMappable {
    func map(_ input: LoginModelAction) -> LoginViewAction
    func map(_ input: [LoginModelAction]) -> [LoginViewAction]
}

final class LoginViewActionMapper: LoginViewActionMappable {
    func map(_ input: LoginModelAction) -> LoginViewAction {
        let viewAction = LoginViewAction(
            identifier: input.identifier,
            title: mapTitle(input),
            associatedIcon: mapAssociatedIcon(input),
            type: input.type
        )
        return viewAction
    }

    func map(_ input: [LoginModelAction]) -> [LoginViewAction] {
        return input.map(map)
    }

    private func mapTitle(_ input: LoginModelAction) -> String {
        switch input.type {
        case .signInViaPhoneNumber:
            return L10n.LoginScreen.signInViaMobilePhone
        case .signInViaFacebook:
            return L10n.LoginScreen.signInViaFacebook
        case .signInViaAppleID:
            return L10n.LoginScreen.signInViaApple
        }
    }

    private func mapAssociatedIcon(_ input: LoginModelAction) -> String {
        switch input.type {
        case .signInViaPhoneNumber:
            return Asset.Images.signInMobile.name
        case .signInViaFacebook:
            return Asset.Images.signInMobile.name
        case .signInViaAppleID:
            return Asset.Images.signInApple.name
        }
    }
}
