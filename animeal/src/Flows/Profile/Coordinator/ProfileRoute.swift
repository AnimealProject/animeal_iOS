// System
import UIKit

// SDK
import Services

enum ProfileRoute {
    case done
    case cancel
    case confirm(UserProfileCodeDeliveryDetails, UserProfileAttribute)
    case picker(@MainActor () -> UIViewController?)
}
