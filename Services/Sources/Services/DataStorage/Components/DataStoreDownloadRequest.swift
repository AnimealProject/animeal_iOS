import Foundation

public enum DataStoreDownloadRequest {
    /// Options to adjust the behavior of this request
    public struct Options {
        /// Access level of the storage system.
        public let accessLevel: DataStoreAccessLevel

        /// Target user to apply the action on.
        public let targetIdentityId: String?

        public init(
            accessLevel: DataStoreAccessLevel = .guest,
            targetIdentityId: String? = nil
        ) {
            self.accessLevel = accessLevel
            self.targetIdentityId = targetIdentityId
        }
    }
}
