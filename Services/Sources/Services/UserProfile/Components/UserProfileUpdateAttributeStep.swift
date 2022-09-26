import Foundation

public enum UserProfileUpdateAttributeStep {
    /// Next step is to confirm the attribute with confirmation code.
    ///
    /// Invoke Auth.confirm(userAttribute: ...) to confirm the attribute that was updated.
    /// `UserProfileCodeDeliveryDetails` provides the details to which the confirmation
    /// code was send and `UserProfileAdditionalInfo` will provide more details if present.
    case confirmAttributeWithCode(UserProfileCodeDeliveryDetails, UserProfileAdditionalInfo?)

    /// Update Attribute step is `done` when the update attribute flow is complete.
    case done
}
