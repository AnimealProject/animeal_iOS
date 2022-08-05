import Foundation

public struct AuthenticationSignUpState {
    /// Indicate whether the signUp flow is completed.
    public var isSignupComplete: Bool {
        switch nextStep {
        case .done:
            return true
        default:
            return false
        }
    }

    /// Shows the next step required to complete the signUp flow.
    ///
    public let nextStep: AuthenticationSignUpStep

    public init(_ nextStep: AuthenticationSignUpStep) {
        self.nextStep = nextStep
    }
}
