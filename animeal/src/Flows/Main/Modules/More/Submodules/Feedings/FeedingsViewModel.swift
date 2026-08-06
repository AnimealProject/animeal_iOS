import Foundation
import Amplify
import Services

enum FeedingReview {
    case notReviewedYet
    case autoApproved
    case reviewedBy(FeedingListItem.User)
}

struct FeedingListItem: Identifiable {
    typealias UserNamesMap = [String: String]

    struct User {
        let userId: String
        let userName: String?
    }

    private enum Constants {
        static let systemModeratorId = "System"
    }

    let id: String
    let user: User
    let review: FeedingReview
    let address: String
    let status: FeedingStatus
    let feedingPointImageURL: URL?
    let imageURLs: [URL]
    let rejectionReason: String?
    let date: Date

    init(
        _ feeding: Feeding,
        userName: String?,
        moderatorName: String?,
        feedingPointImageURL: URL?,
        imageURLs: [URL]
    ) {
        self.id = feeding.id
        self.user = User(userId: feeding.userId, userName: userName)
        self.review = Self.makeReview(moderatedBy: feeding.moderatedBy, moderatorName: moderatorName)
        self.address = feeding.feedingPointDetails?.address ?? ""
        self.status = feeding.status
        self.feedingPointImageURL = feedingPointImageURL
        self.imageURLs = imageURLs
        self.rejectionReason = nil
        self.date = feeding.createdAt.foundationDate
    }

    init(
        _ history: FeedingHistory,
        userName: String?,
        moderatorName: String?,
        feedingPointImageURL: URL?,
        imageURLs: [URL]
    ) {
        self.id = history.id
        self.user = User(userId: history.userId, userName: userName)
        self.review = Self.makeReview(moderatedBy: history.moderatedBy, moderatorName: moderatorName)
        self.address = history.feedingPointDetails?.address ?? ""
        self.status = history.status ?? .outdated
        self.feedingPointImageURL = feedingPointImageURL
        self.imageURLs = imageURLs
        self.rejectionReason = history.reason
        self.date = history.updatedAt.foundationDate
    }

    private static func makeReview(moderatedBy: String?, moderatorName: String?) -> FeedingReview {
        guard let moderatedBy else { return .notReviewedYet }
        guard moderatedBy != Constants.systemModeratorId else { return .autoApproved }
        return .reviewedBy(User(userId: moderatedBy, userName: moderatorName))
    }
}

enum FeedingTabState {
    case isLoading
    case loaded([FeedingListItem])
    case failed(String)
}

@Observable
final class FeedingsViewModel {
    private enum Constants {
        static let approveReason = "The request includes all necessary details."
    }

    // MARK: - Published state
    private(set) var tabStates: [FeedingStatus: FeedingTabState] = [:]
    private(set) var isProcessingAction = false
    private(set) var hasReviewedFeedingsThisSession = false
    var actionErrorMessage: String?

    // MARK: - Dependencies
    private let coordinator: MorePartitionCoordinatable
    private let networkService: NetworkServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
    private let dataStoreService: DataStoreServiceProtocol
    private let seenTracker: FeedingsSeenTrackerProtocol

    @ObservationIgnored private var feedingPointCoverCache: [String: URL?] = [:]

    init(
        coordinator: MorePartitionCoordinatable,
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        userProfileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService,
        dataStoreService: DataStoreServiceProtocol = AppDelegate.shared.context.dataStoreService,
        seenTracker: FeedingsSeenTrackerProtocol = FeedingsSeenTracker()
    ) {
        self.coordinator = coordinator
        self.networkService = networkService
        self.userProfileService = userProfileService
        self.dataStoreService = dataStoreService
        self.seenTracker = seenTracker

        tabStates = Dictionary(
            uniqueKeysWithValues: [FeedingStatus.pending, .approved, .rejected, .outdated]
                .map { ($0, .isLoading) }
        )
    }

    @MainActor
    func goBack() {
        coordinator.routeTo(.back)
    }

    // MARK: - Moderation actions

    @MainActor
    func approve(_ item: FeedingListItem) async {
        await performAction(destination: .approved) {
            _ = try await networkService.query(
                request: .customMutation(
                    ApproveFeedingMutation(feedingId: item.id, reason: Constants.approveReason)
                )
            )
        }
    }

    @MainActor
    func reject(_ item: FeedingListItem, reason: String) async {
        await performAction(destination: .rejected) {
            _ = try await networkService.query(
                request: .customMutation(
                    RejectFeedingMutation(feedingId: item.id, reason: reason)
                )
            )
        }
    }

    @MainActor
    private func performAction(destination: FeedingStatus, _ action: () async throws -> Void) async {
        guard !isProcessingAction else { return }
        isProcessingAction = true
        defer { isProcessingAction = false }

        do {
            try await action()
            hasReviewedFeedingsThisSession = true
            await warmUserNamesCache()
            async let pending: Void = load(status: .pending)
            async let destinationTab: Void = load(status: destination)
            _ = await (pending, destinationTab)
        } catch {
            actionErrorMessage = L10n.Errors.somethingWrong.asBaseError().description
        }
    }

    // MARK: - Loading

    @MainActor
    func loadAll() async {
        await warmUserNamesCache()

        async let pendingItem = load(status: .pending)
        async let approvedItem = load(status: .approved)
        async let rejectedItems = load(status: .rejected)
        async let outdatedItems = load(status: .outdated)

        _ = await (pendingItem, approvedItem, rejectedItems, outdatedItems)
    }

    private func warmUserNamesCache() async {
        _ = try? await userProfileService.fetchUserNames(for: [])
    }

    @MainActor
    func load(status: FeedingStatus) async {
        tabStates[status] = .isLoading

        do {
            let items = try await fetchItems(for: status)
            tabStates[status] = .loaded(items)
        } catch {
            tabStates[status] = .failed(L10n.Errors.somethingWrong.asBaseError().description)
        }
    }

    private func fetchItems(for status: FeedingStatus) async throws -> [FeedingListItem] {
        let items: [FeedingListItem]
        if status == .pending {
            items = try await fetchPendingItems()
        } else {
            items = try await fetchHistoryItems(for: status)
        }
        return items.sorted { $0.date < $1.date }
    }

    private func fetchPendingItems() async throws -> [FeedingListItem] {
        let feedings = try await networkService.query(
            request: .getActiveFeedings(status: FeedingStatus.pending.rawValue)
        )
        seenTracker.markSeen(feedings.map(\.id))

        let userIds = Set(feedings.map(\.userId))
        let moderatorIds = Set(feedings.compactMap(\.moderatedBy))
        let users = try await userProfileService.fetchUserNames(for: Array(userIds.union(moderatorIds)))

        let imageMap = await dataStoreService.getURLs(for: feedings.map { ($0.id, $0.images) })
        let feedingPointImageMap = await resolveFeedingPointImageURLs(
            for: Set(feedings.map(\.feedingPointFeedingsId))
        )

        return feedings.map {
            FeedingListItem(
                $0,
                userName: users[$0.userId],
                moderatorName: $0.moderatedBy.flatMap { users[$0] },
                feedingPointImageURL: feedingPointImageMap[$0.feedingPointFeedingsId],
                imageURLs: imageMap[$0.id] ?? []
            )
        }
    }

    private func fetchHistoryItems(for status: FeedingStatus) async throws -> [FeedingListItem] {
        let history = try await networkService.query(request: .getHistoricalFeedings(status: status.rawValue))

        let userIds = Set(history.map(\.userId))
        let moderatorIds = Set(history.compactMap(\.moderatedBy))
        let users = try await userProfileService.fetchUserNames(for: Array(userIds.union(moderatorIds)))

        let imageMap = await dataStoreService.getURLs(for: history.map { ($0.id, $0.images) })
        let feedingPointImageMap = await resolveFeedingPointImageURLs(
            for: Set(history.map(\.feedingPointId))
        )

        return history.map {
            FeedingListItem(
                $0,
                userName: users[$0.userId],
                moderatorName: $0.moderatedBy.flatMap { users[$0] },
                feedingPointImageURL: feedingPointImageMap[$0.feedingPointId],
                imageURLs: imageMap[$0.id] ?? []
            )
        }
    }

    private enum ImageResolution {
        static let maxConcurrentCoverFetches = 5
    }

    @MainActor
    private func resolveFeedingPointImageURLs(for feedingPointIds: Set<String>) async -> [String: URL] {
        let missing = feedingPointIds.filter { feedingPointCoverCache[$0] == nil }
        if !missing.isEmpty {
            let resolved = await fetchCoverURLs(for: missing)
            for (id, url) in resolved { feedingPointCoverCache[id] = url }
        }

        return feedingPointIds.reduce(into: [:]) { result, id in
            if let cached = feedingPointCoverCache[id], let url = cached {
                result[id] = url
            }
        }
    }

    private func fetchCoverURLs(for feedingPointIds: Set<String>) async -> [String: URL?] {
        let networkService = networkService
        let dataStoreService = dataStoreService

        return await withTaskGroup(of: (String, URL?).self) { group in
            var pending = feedingPointIds.makeIterator()

            func addTask(for id: String) {
                group.addTask {
                    guard let point = try? await networkService.query(
                        request: .get(FeedingPoint.self, byId: id)
                    ), let cover = point.cover else {
                        return (id, nil)
                    }
                    return (id, try? await dataStoreService.getURL(key: cover))
                }
            }

            for _ in 0..<ImageResolution.maxConcurrentCoverFetches {
                guard let id = pending.next() else { break }
                addTask(for: id)
            }

            var result: [String: URL?] = [:]
            while let (id, url) = await group.next() {
                result[id] = url
                if let next = pending.next() { addTask(for: next) }
            }
            return result
        }
    }
}
