//
//  VerificationModelCodeError.swift
//  animeal
//
//  Created by Диана Тынкован on 26.09.22.
//

import Foundation

enum VerificationModelCodeError: LocalizedError {
    case codeDigitsCountDoesNotFit
    case codeRequestTimeLimitExceeded
    case codeUnsupportedNextStep

    var errorDescription: String? {
        switch self {
        case .codeDigitsCountDoesNotFit:
            return L10n.Verification.Error.codeDigitsCountDoesNotFit
        case .codeRequestTimeLimitExceeded:
            return L10n.Verification.Error.codeRequestTimeLimitExceeded
        case .codeUnsupportedNextStep:
            return L10n.Verification.Error.codeUnsupportedNextStep
        }
    }
}
