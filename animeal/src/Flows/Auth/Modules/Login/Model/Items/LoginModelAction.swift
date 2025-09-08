//
//  LoginModelAction.swift
//  animeal
//
//  Created by Диана Тынкован on 1.06.22.
//

import Foundation
import Services

enum LoginActionType: String {
    case signInViaPhoneNumber
    case signInViaAppleID
    case signInAsGuest

    var priority: Int {
        switch self {
        case .signInViaPhoneNumber:
            return 0
        case .signInViaAppleID:
            return 1
        case .signInAsGuest:
            return 2
        }
    }
}

extension LoginActionType {
    struct StorableKey: LocalStorageKeysProtocol {
        let rawValue: String
    }

    static let storableKey = StorableKey(
        rawValue: String(describing: LoginActionType.self)
    )
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
        case .signInViaAppleID:
            return false
        case .signInAsGuest:
            return false
        }
    }
}
