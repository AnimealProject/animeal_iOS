// System
import Foundation

// SDK
import Services

enum CustomAuthModelNextStep {
    case confirm(AuthenticationCodeDeliveryDetails)
    case setNewPassword
    case resetPassword
    case done
    case unknown
}
