import Foundation

public struct UserProfile {
    /// User name of the auth user
    public let username: String

    /// Unique id of the auth user
    public let userId: String

    public init(username: String, userId: String) {
        self.username = username
        self.userId = userId
    }
}
