import Foundation

public enum AuthenticationSignInStep {

    /// Auth step is SMS multi factor authentication.
    ///
    /// Confirmation code will be send to the provided SMS.
    case confirmSignInWithSMSCode(AuthenticationCodeDeliveryDetails, AuthenticationAdditionalInfo?)

    /// Auth step is in a custom challenge depending on the plugin.
    case confirmSignInWithCustomChallenge(AuthenticationAdditionalInfo?)

    /// Auth step required the user to give a new password.
    case confirmSignInWithNewPassword(AuthenticationAdditionalInfo?)

    /// Auth step required the user to change their password.
    case resetPassword(AuthenticationAdditionalInfo?)

    /// Auth step that required the user to be confirmed
    case confirmSignUp(AuthenticationAdditionalInfo?)

    /// There is no next step and the signIn flow is complete
    case done
}
