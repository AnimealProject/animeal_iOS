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
    let date: Date

    init(_ feeding: Feeding, userName: String?, moderatorName: String?) {
        id = feeding.id
        user = User(userId: feeding.userId, userName: userName)
        review = Self.makeReview(moderatedBy: feeding.moderatedBy, moderatorName: moderatorName)
        address = feeding.feedingPointDetails?.address ?? ""
        status = feeding.status
        date = feeding.createdAt.foundationDate
    }

    init(_ history: FeedingHistory, userName: String?, moderatorName: String?) {
        id = history.id
        user = User(userId: history.userId, userName: userName)
        review = Self.makeReview(moderatedBy: history.moderatedBy, moderatorName: moderatorName)
        address = history.feedingPointDetails?.address ?? ""
        status = history.status ?? .outdated
        date = history.updatedAt.foundationDate
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

    // MARK: - Published state
    private(set) var tabStates: [FeedingStatus: FeedingTabState] = [:]

    // MARK: - Dependencies
    private let coordinator: MorePartitionCoordinatable
    private let networkService: NetworkServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
    private let seenTracker: FeedingsSeenTrackerProtocol

    init(
        coordinator: MorePartitionCoordinatable,
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        userProfileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService,
        seenTracker: FeedingsSeenTrackerProtocol = FeedingsSeenTracker()
    ) {
        self.coordinator = coordinator
        self.networkService = networkService
        self.userProfileService = userProfileService
        self.seenTracker = seenTracker

        tabStates = Dictionary(
            uniqueKeysWithValues: [FeedingStatus.pending, .approved, .rejected, .outdated]
                .map { ($0, .isLoading) }
        )
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
        if status == .pending {
            let feedings = try await networkService.query(request: .getActiveFeedings(status: status.rawValue))
            seenTracker.markSeen(feedings.map(\.id))

            let userIds = Set(feedings.map(\.userId))
            let moderatorIds = Set(feedings.compactMap(\.moderatedBy))
            let users = try await userProfileService.fetchUserNames(for: Array(userIds.union(moderatorIds)))

            return feedings.map {
                FeedingListItem(
                    $0,
                    userName: users[$0.userId],
                    moderatorName: $0.moderatedBy.flatMap { users[$0] }
                )
            }
        } else {
            let history = try await networkService.query(request: .getHistoricalFeedings(status: status.rawValue))

            let userIds = Set(history.map(\.userId))
            let moderatorIds = Set(history.compactMap(\.moderatedBy))
            let users = try await userProfileService.fetchUserNames(for: Array(userIds.union(moderatorIds)))

            return history.map {
                FeedingListItem(
                    $0,
                    userName: users[$0.userId],
                    moderatorName: $0.moderatedBy.flatMap { users[$0] }
                )
            }
        }
    }
}
