// System
import Foundation

// SDK
import Services

enum ProfileModelNextStep {
    case confirm(UserProfileCodeDeliveryDetails, UserProfileAttribute)
    case done
}
