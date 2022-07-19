import Foundation

public typealias AuthenticationDestination = String

/// Destination to where an item (e.g., confirmation code) was delivered
public enum AuthenticationDeliveryDestination {
    /// Email destination with optional associated value containing the email info
    case email(AuthenticationDestination?)

    /// Phone destination with optional associated value containing the phone number info
    case phone(AuthenticationDestination?)

    /// SMS destination with optional associated value containing the number info
    case sms(AuthenticationDestination?)

    /// Unknown destination with optional associated value destination detail
    case unknown(AuthenticationDestination?)
}
