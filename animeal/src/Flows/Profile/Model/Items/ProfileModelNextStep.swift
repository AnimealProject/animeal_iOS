// System
import Foundation

// SDK
import Services

enum ProfileModelNextStep {
    case confirm(UserProfileCodeDeliveryDetails, UserProfileAttribute, ResendMethod)
    case done
}
