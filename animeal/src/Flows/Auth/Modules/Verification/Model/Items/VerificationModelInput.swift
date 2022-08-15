import Foundation

enum VerificationDestination {
    case sms(String)
    case email(String)
    case phone(String)
    case unknown
}

enum VerificationStep {
    case signIn(VerificationDestination)
    case signUp(VerificationDestination)
}

typealias VerificationModelInput = VerificationStep
