import Foundation

// sourcery: AutoMockable
protocol FeedingsSeenTrackerProtocol {
    func hasUnseen(among feedingIds: [String]) -> Bool
    func markSeen(_ feedingIds: [String])
}

final class FeedingsSeenTracker: FeedingsSeenTrackerProtocol {
    private enum Constants {
        static let seenPendingFeedingIdsKey = "com.animeal.feedings.seenPendingFeedingIds"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func hasUnseen(among feedingIds: [String]) -> Bool {
        let seenIds = storedSeenIds()
        return feedingIds.contains { !seenIds.contains($0) }
    }

    func markSeen(_ feedingIds: [String]) {
        let merged = storedSeenIds().union(feedingIds)
        defaults.set(Array(merged), forKey: Constants.seenPendingFeedingIdsKey)
    }

    private func storedSeenIds() -> Set<String> {
        Set(defaults.stringArray(forKey: Constants.seenPendingFeedingIdsKey) ?? [])
    }
}
