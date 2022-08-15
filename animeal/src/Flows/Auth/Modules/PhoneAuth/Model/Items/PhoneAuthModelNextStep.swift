// System
import Foundation

// SDK
import Services

enum PhoneAuthModelNextStep {
    case confirm(AuthenticationDeliveryDestination)
    case setNewPassword
    case resetPassword
    case done
    case unknown
}
