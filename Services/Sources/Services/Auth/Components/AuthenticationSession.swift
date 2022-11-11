import Foundation

public struct AuthenticationSession {
    /// Indicates whether a user is signed in or not
    ///
    /// `true` if a user is authenticated. `isSignedIn` remains `true` till we call `Amplify.Auth.signOut`.
    /// Please note that this value remains `true` even when the session is expired. Refer the underlying plugin
    /// documentation regarding how to handle session expiry.
    public let isSignedIn: Bool

    public init(isSignedIn: Bool) {
        self.isSignedIn = isSignedIn
    }
}
