import Foundation

typealias LoginModelFailureReason = String

enum LoginModelStatus {
    case authentificated
    case confirmationCodeSent
    case resetPassword
    case failure(LoginModelFailureReason)
}
