import Foundation

public enum AuthenticationSignUpStep {
    /// Need to confirm the user
    case confirmUser(AuthenticationCodeDeliveryDetails?, AuthenticationAdditionalInfo?)

    /// Sign up is complete
    case done
}
