//
//  LoginModelAction.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import Foundation

enum LoginActionType: String {
    case signInViaPhoneNumber
    case signInViaFacebook
    case signInViaAppleID
}

struct LoginModelAction {
    let type: LoginActionType

    var identifier: String {
        return type.rawValue
    }
}
