// System
import Foundation

// SDK
import Services

struct VerificationModelCodeDeliveryDetails {
    let destination: AuthenticationDeliveryDestination
    let attributeKey: AuthenticationUserAttributeKey?
}

enum VerificationModelNextStep {
    case confirmSignInWithSMSMFACode(VerificationModelCodeDeliveryDetails)
    case confirmSignInWithCustomChallenge
    case confirmSignInWithNewPassword
    case resetPassword
    case confirmSignUp
    case done
}
