import Foundation

/// Details on where the code has been delivered
public struct AuthenticationCodeDeliveryDetails {
    /// Destination to which the code was delivered.
    public let destination: AuthenticationDeliveryDestination

    /// Attribute that is confirmed or verified.
    public let attributeKey: AuthenticationUserAttributeKey?

    public init(
        destination: AuthenticationDeliveryDestination,
        attributeKey: AuthenticationUserAttributeKey? = nil
    ) {
        self.destination = destination
        self.attributeKey = attributeKey
    }
}
