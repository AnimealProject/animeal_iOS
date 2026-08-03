//
//  FeedingsViewModel.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

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
        isProcessingAction = true
        defer { isProcessingAction = false }

        do {
            try await action()
            hasReviewedFeedingsThisSession = true
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
        async let pendingItem = load(status: .pending)
        async let approvedItem = load(status: .approved)
        async let rejectedItems = load(status: .rejected)
        async let outdatedItems = load(status: .outdated)

        _ = await (pendingItem, approvedItem, rejectedItems, outdatedItems)
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
            items = try await fetchPendingItems(for: status)
        } else {
            items = try await fetchHistoryItems(for: status)
        }
        return items.sorted { $0.date < $1.date }
    }

    private func fetchPendingItems(for status: FeedingStatus) async throws -> [FeedingListItem] {
        let feedings = try await networkService.query(request: .getActiveFeedings(status: status.rawValue))
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

    private func resolveFeedingPointImageURLs(for feedingPointIds: Set<String>) async -> [String: URL] {
        await withTaskGroup { group in
            for feedingPointId in feedingPointIds {
                group.addTask { [weak self] in
                    guard let self else { return (feedingPointId, nil as URL?) }
                    guard let point = try? await self.networkService.query(
                        request: .get(FeedingPoint.self, byId: feedingPointId)
                    ), let cover = point.cover else {
                        return (feedingPointId, nil)
                    }
                    let url = try? await self.dataStoreService.getURL(key: cover)
                    return (feedingPointId, url)
                }
            }

            var result: [String: URL] = [:]
            for await (id, url) in group { result[id] = url }
            return result
        }
    }
}
