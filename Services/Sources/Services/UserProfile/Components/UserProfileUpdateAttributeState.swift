import Foundation

public struct UserProfileUpdateAttributeState {
    /// Informs whether the user attribute is complete or not
    public let isUpdated: Bool

    /// Shows the next step required to complete update attribute flow.
    public let nextStep: UserProfileUpdateAttributeStep

    public init(isUpdated: Bool, nextStep: UserProfileUpdateAttributeStep) {
        self.isUpdated = isUpdated
        self.nextStep = nextStep
    }
}
