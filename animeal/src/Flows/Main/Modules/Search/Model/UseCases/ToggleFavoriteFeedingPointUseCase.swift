// System
import Foundation

// SDK
import Services
import Common

protocol ToggleFavoriteFeedingPointUseCaseLogic {
    func callAsFunction(byIdentifier identifier: String) async
}

final class ToggleFavoriteFeedingPointUseCase: ToggleFavoriteFeedingPointUseCaseLogic {
    private let feedingPointsService: FeedingPointsServiceProtocol

    init(
        feedingPointsService: FeedingPointsServiceProtocol = AppDelegate.shared.context.feedingPointsService
    ) {
        self.feedingPointsService = feedingPointsService
    }

    func callAsFunction(byIdentifier identifier: String) async {
        do {
            try await feedingPointsService.toggleFavorite(byIdentifier: identifier)
        } catch {
            logError("[ToggleFavoriteFeedingPointUseCase] Impossible to add/delete feeding point.")
        }
    }
}
