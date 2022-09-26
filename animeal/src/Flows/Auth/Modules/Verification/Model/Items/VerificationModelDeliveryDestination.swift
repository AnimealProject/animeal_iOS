// System
import Foundation

// SDK
import Common
import Services

typealias VerificationModelDeliveryDestination = AuthenticationDeliveryDestination

extension VerificationModelDeliveryDestination {
    var value: String? {
        switch self {
        case .sms(let value),
                .phone(let value),
                .email(let value),
                .unknown(let value):
            return value
        }
    }
}
