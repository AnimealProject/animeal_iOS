// System
import UIKit

// SDK
import Services

enum CustomAuthRoute {
    case codeConfirmation(AuthenticationCodeDeliveryDetails)
    case resetPassword
    case setNewPassword
    case done
    case picker(@MainActor () -> UIViewController?)
}
