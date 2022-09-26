// System
import Foundation

// SDK
import Services

enum CustomAuthRoute {
    case codeConfirmation(AuthenticationCodeDeliveryDetails)
    case resetPassword
    case setNewPassword
    case done
}
