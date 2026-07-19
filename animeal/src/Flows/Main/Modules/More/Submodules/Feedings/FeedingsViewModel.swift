//
//  FeedingsViewModel.swift
//  animeal
//
//  Created by Luka Alimbarashvili on 07.05.26.
//

import Foundation
import Amplify
import Services

struct FeedingListItem: Identifiable {
    let id: String
    let address: String
    let status: FeedingStatus
    let date: Date

    init(_ feeding: Feeding) {
        id = feeding.id
        address = feeding.feedingPointDetails?.address ?? ""
        status = feeding.status
        date = feeding.createdAt.foundationDate
    }

    init(_ history: FeedingHistory) {
        id = history.id
        address = history.feedingPointDetails?.address ?? ""
        status = history.status ?? .outdated
        date = history.updatedAt.foundationDate
    }
}

@Observable
final class FeedingsViewModel {

    // MARK: - Published state
    private(set) var items: [FeedingListItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let coordinator: MorePartitionCoordinatable
    private let networkService: NetworkServiceProtocol
    private let seenTracker: FeedingsSeenTrackerProtocol

    init(
        coordinator: MorePartitionCoordinatable,
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        seenTracker: FeedingsSeenTrackerProtocol = FeedingsSeenTracker()
    ) {
        self.coordinator = coordinator
        self.networkService = networkService
        self.seenTracker = seenTracker
    }

    // MARK: - Loading

    @MainActor
    func load(status: FeedingStatus) async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await fetchItems(for: status)
        } catch {
            items = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func fetchItems(for status: FeedingStatus) async throws -> [FeedingListItem] {
        if status == .pending {
            let feedings = try await networkService.query(request: .getActiveFeedings(status: status.rawValue))
            seenTracker.markSeen(feedings.map(\.id))
            return feedings.map(FeedingListItem.init)
        } else {
            let history = try await networkService.query(request: .getHistoricalFeedings(status: status.rawValue))
            return history.map(FeedingListItem.init)
        }
    }
}
