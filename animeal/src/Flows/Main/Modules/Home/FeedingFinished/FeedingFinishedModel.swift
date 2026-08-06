import Foundation

final class FeedingFinishedModel: FeedingFinishedModelProtocol, ObservableObject {
    /// Trusted users' feedings are auto-approved; non-trusted ones go to moderation,
    /// which changes the subtitle copy on the "Thank You" screen (EPMEDU-1225).
    let isTrusted: Bool

    // MARK: - Initialization
    init(isTrusted: Bool) {
        self.isTrusted = isTrusted
    }
}
