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

    var priority: Int {
        switch self {
        case .signInViaPhoneNumber:
            return 0
        case .signInViaFacebook:
            return 1
        case .signInViaAppleID:
            return 2
        }
    }
}

struct LoginModelAction {
    let type: LoginActionType

    var identifier: String {
        return type.rawValue
    }

    var isCustomAuthenticationSupported: Bool {
        switch type {
        case .signInViaPhoneNumber:
            return true
        case .signInViaFacebook:
            return false
        case .signInViaAppleID:
            return false
        }
    }
}
