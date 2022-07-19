import Foundation

public struct AuthenticationSignInState {
    /// Informs whether the user is signedIn or not.
    ///
    /// When this value is false, it means that there are more steps to follow for the signIn flow. Check `nextStep`
    /// to understand the next flow. If `isSignedIn` is true, signIn flow has been completed.
    public var isSignedIn: Bool {
        switch nextStep {
        case .done:
            return true
        default:
            return false
        }
    }

    /// Shows the next step required to complete the signIn flow.
    ///
    public var nextStep: AuthenticationSignInStep

    public init(nextStep: AuthenticationSignInStep) {
        self.nextStep = nextStep
    }
}
