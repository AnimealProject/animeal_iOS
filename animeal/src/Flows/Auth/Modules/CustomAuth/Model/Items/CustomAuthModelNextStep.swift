// System
import Foundation

// SDK
import Services

enum CustomAuthModelNextStep {
    case confirm(AuthenticationDeliveryDestination)
    case setNewPassword
    case resetPassword
    case done
    case unknown
}
