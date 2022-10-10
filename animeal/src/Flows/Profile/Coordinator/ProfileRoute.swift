// System
import Foundation

// SDK
import Services

enum ProfileRoute {
    case done
    case cancel
    case confirm(UserProfileCodeDeliveryDetails, UserProfileAttribute)
}
