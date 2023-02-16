// System
import Foundation
import Combine

// SDK
import Services
import Common
import Amplify

struct FavouriteFeedingPoint: Hashable {
    let feedingPoint: FeedingPoint
    let isFavorite: Bool

    init(feedingPoint: FeedingPoint, isFavorite: Bool = true) {
        self.feedingPoint = feedingPoint
        self.isFavorite = isFavorite
    }
}

extension FavouriteFeedingPoint {
    var identifier: String {
        feedingPoint.id
    }
}

protocol FavoritesServiceHolder {
    var favoritesService: FavoritesServiceProtocol { get }
}

protocol FavoritesServiceProtocol: AnyObject {
    var favoriteFeedingPoints: AnyPublisher<[FavouriteFeedingPoint], Never> { get }
    var changedFavoriteFeedingPoint: AnyPublisher<FavouriteFeedingPoint, Never> { get }

    func fetchAll() async throws -> [FavouriteFeedingPoint]

    @discardableResult
    func add(_ feedingPoint: FeedingPoint) async throws -> FavouriteFeedingPoint
    @discardableResult
    func delete(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
}

final class FavoritesService: FavoritesServiceProtocol {
    // MARK: - Subjects
    private let innerFavoriteFeedingPoints = CurrentValueSubject<[FavouriteFeedingPoint], Never>([])
    private let innerChangedFavoriteFeedingPoint = PassthroughSubject<FavouriteFeedingPoint, Never>()

    // MARK: - Publishers
    var favoriteFeedingPoints: AnyPublisher<[FavouriteFeedingPoint], Never> {
        innerFavoriteFeedingPoints.eraseToAnyPublisher()
    }

    var changedFavoriteFeedingPoint: AnyPublisher<FavouriteFeedingPoint, Never> {
        innerChangedFavoriteFeedingPoint.eraseToAnyPublisher()
    }

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let profileService: UserProfileServiceProtocol

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        profileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService
    ) {
        self.networkService = networkService
        self.profileService = profileService
    }

    func fetchAll() async throws -> [FavouriteFeedingPoint] {
        let userId = profileService.getCurrentUser()?.userId ?? ""
        let favouriteKeys = Favourite.keys
        let predicate = favouriteKeys.userId == userId
        let favorites = try await networkService.query(
            request: .list(Favourite.self, where: predicate)
        )
        .map { FavouriteFeedingPoint(feedingPoint: $0.feedingPoint) }
        innerFavoriteFeedingPoints.send(favorites)
        return favorites
    }

    @discardableResult
    func add(_ feedingPoint: FeedingPoint) async throws -> FavouriteFeedingPoint {
        guard
            let userId = profileService.getCurrentUser()?.userId,
            !innerFavoriteFeedingPoints.value.contains(where: { $0.identifier == feedingPoint.id })
        else {
            throw "Feeding point cannot be added to the Favorites.".asBaseError()
        }

        let favourite = Favourite(
            userId: userId,
            feedingPointId: feedingPoint.id,
            feedingPoint: feedingPoint
        )
        let request: Request<Favourite> = .create(favourite)
        let response = try await networkService.mutate(request: request)
        let favouriteFeedingPoint = FavouriteFeedingPoint(
            feedingPoint: response.feedingPoint
        )

        innerChangedFavoriteFeedingPoint.send(favouriteFeedingPoint)
        updateFavoriteFeedingPoints { favoriteFeedingPoints in
            var favoriteFeedingPoints = favoriteFeedingPoints
            favoriteFeedingPoints.append(favouriteFeedingPoint)
            return favoriteFeedingPoints
        }

        return favouriteFeedingPoint
    }

    @discardableResult
    func delete(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard
            let userId = profileService.getCurrentUser()?.userId,
            let feedingPointIndex = innerFavoriteFeedingPoints.value.firstIndex(
                where: { $0.identifier == identifier }
            )
        else {
            throw "Feeding point cannot be deleted from the Favorites.".asBaseError()
        }

        let favouriteFeedingPoint = innerFavoriteFeedingPoints.value[feedingPointIndex]

        let favourite = Favourite(
            userId: userId,
            feedingPointId: favouriteFeedingPoint.identifier,
            feedingPoint: favouriteFeedingPoint.feedingPoint
        )
        let request: Request<Favourite> = .delete(favourite)
        let response = try await networkService.mutate(request: request)

        innerChangedFavoriteFeedingPoint.send(
            .init(feedingPoint: response.feedingPoint, isFavorite: false)
        )
        updateFavoriteFeedingPoints { favoriteFeedingPoints in
            var favoriteFeedingPoints = favoriteFeedingPoints
            favoriteFeedingPoints.remove(at: feedingPointIndex)
            return favoriteFeedingPoints
        }

        return favouriteFeedingPoint
    }
}

private extension FavoritesService {
    func updateFavoriteFeedingPoints(_ modify: ([FavouriteFeedingPoint]) -> [FavouriteFeedingPoint]) {
        let favoriteFeedingPoints = innerFavoriteFeedingPoints.value
        let modifiedFeedingPoints = modify(favoriteFeedingPoints)
        innerFavoriteFeedingPoints.send(modifiedFeedingPoints)
    }
}
