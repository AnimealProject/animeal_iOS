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
    let imageURL: URL?
    let date: Date

    init(_ feeding: Feeding, userName: String?, moderatorName: String?, imageURL: URL?) {
        self.id = feeding.id
        self.user = User(userId: feeding.userId, userName: userName)
        self.review = Self.makeReview(moderatedBy: feeding.moderatedBy, moderatorName: moderatorName)
        self.address = feeding.feedingPointDetails?.address ?? ""
        self.status = feeding.status
        self.imageURL = imageURL
        self.date = feeding.createdAt.foundationDate
    }

    init(_ history: FeedingHistory, userName: String?, moderatorName: String?, imageURL: URL?) {
        self.id = history.id
        self.user = User(userId: history.userId, userName: userName)
        self.review = Self.makeReview(moderatedBy: history.moderatedBy, moderatorName: moderatorName)
        self.address = history.feedingPointDetails?.address ?? ""
        self.status = history.status ?? .outdated
        self.imageURL = imageURL
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
        await performAction {
            _ = try await networkService.query(
                request: .customMutation(
                    ApproveFeedingMutation(feedingId: item.id, reason: Constants.approveReason)
                )
            )
        }
    }

    @MainActor
    func reject(_ item: FeedingListItem, reason: String) async {
        await performAction {
            _ = try await networkService.query(
                request: .customMutation(
                    RejectFeedingMutation(feedingId: item.id, reason: reason)
                )
            )
        }
    }

    @MainActor
    private func performAction(_ action: () async throws -> Void) async {
        isProcessingAction = true
        defer { isProcessingAction = false }

        do {
            try await action()
            await load(status: .pending)
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

        let imageMap: [String: URL] = await withTaskGroup { group in
            for feeding in feedings {
                group.addTask { [weak self] in
                    let url = try? await self?.dataStoreService.getURL(key: feeding.images.first)
                    return (feeding.id, url)
                }
            }

            var result: [String: URL] = [:]
            for await (id, url) in group { result[id] = url }
            return result
        }

        return feedings.map {
            FeedingListItem(
                $0,
                userName: users[$0.userId],
                moderatorName: $0.moderatedBy.flatMap { users[$0] },
                imageURL: imageMap[$0.id]
            )
        }
    }

    private func fetchHistoryItems(for status: FeedingStatus) async throws -> [FeedingListItem] {
        let history = try await networkService.query(request: .getHistoricalFeedings(status: status.rawValue))

        let userIds = Set(history.map(\.userId))
        let moderatorIds = Set(history.compactMap(\.moderatedBy))
        let users = try await userProfileService.fetchUserNames(for: Array(userIds.union(moderatorIds)))

        let imageMap: [String: URL] = await withTaskGroup { group in
            for feeding in history {
                group.addTask { [weak self] in
                    let url = try? await self?.dataStoreService.getURL(key: feeding.images.first)
                    return (feeding.id, url)
                }
            }

            var result: [String: URL] = [:]
            for await (id, url) in group {
                result[id] = url
            }
            return result
        }

        return history.map {
            FeedingListItem(
                $0,
                userName: users[$0.userId],
                moderatorName: $0.moderatedBy.flatMap { users[$0] },
                imageURL: imageMap[$0.id]
            )
        }
    }
}
