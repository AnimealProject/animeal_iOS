import Foundation

enum VerificationViewActionEvent {
    case tapResendCode
    case changeCode([VerificationViewCodeItem])
}
