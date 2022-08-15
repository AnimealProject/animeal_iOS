import Foundation

enum PhoneAuthValidationError: Error, CustomStringConvertible {
    case incorrectPhoneNumber
    case empty

    var description: String {
        switch self {
        case .incorrectPhoneNumber:
            return L10n.Phone.Errors.incorrectPhone
        case .empty:
            return L10n.Phone.Errors.empty
        }
    }
}
