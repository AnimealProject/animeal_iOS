// System
import Foundation
import Combine

// SDK
import Services
import Common
import Amplify

struct FavouriteFeedingPoint: Hashable {
    let feedingPointId: String
    let isFavorite: Bool
    var imageURL: URL?

    init(
        feedingPointId: String,
        isFavorite: Bool = true,
        imageURL: URL? = nil
    ) {
        self.feedingPointId = feedingPointId
        self.isFavorite = isFavorite
        self.imageURL = imageURL
    }
}

extension FavouriteFeedingPoint {
    var identifier: String {
        feedingPointId
    }
}

protocol FavoritesServiceHolder {
    var favoritesService: FavoritesServiceProtocol { get }
}

protocol FavoritesServiceProtocol: AnyObject {
    var storedFavoriteFeedingPoints: [FavouriteFeedingPoint] { get }
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
    private let innerFavoriteFeedingPoints = CurrentValueSubject<[Favourite], Never>([])
    private let innerChangedFavoriteFeedingPoint = PassthroughSubject<FavouriteFeedingPoint, Never>()

    // MARK: - Properties
    var storedFavoriteFeedingPoints: [FavouriteFeedingPoint] {
        innerFavoriteFeedingPoints
            .value
            .map { FavouriteFeedingPoint(feedingPointId: $0.feedingPointId, isFavorite: true) }
    }

    // MARK: - Publishers
    var favoriteFeedingPoints: AnyPublisher<[FavouriteFeedingPoint], Never> {
        innerFavoriteFeedingPoints
            .map { $0.map { FavouriteFeedingPoint(feedingPointId: $0.feedingPointId, isFavorite: true) } }
            .eraseToAnyPublisher()
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
        let userId = await profileService.getCurrentUser()?.userId ?? ""
        let favouriteKeys = Favourite.keys
        let predicate = favouriteKeys.userId == userId
        let favorites = try await networkService.query(
            request: .list(Favourite.self, where: predicate)
        )
        innerFavoriteFeedingPoints.send(favorites)
        return favorites.map {
            FavouriteFeedingPoint(feedingPointId: $0.feedingPointId, isFavorite: true)
        }
    }

    @discardableResult
    func add(_ feedingPoint: FeedingPoint) async throws -> FavouriteFeedingPoint {
        guard
            let userId = await profileService.getCurrentUser()?.userId,
            !innerFavoriteFeedingPoints.value.contains(
                where: { $0.feedingPointId == feedingPoint.id }
            )
        else {
            throw "[FavoritesService] Feeding point cannot be added to the Favorites.".asBaseError()
        }

        let favourite = Favourite(
            userId: userId,
            feedingPointId: feedingPoint.id
        )
        let request: Request<Favourite> = .create(favourite)
        let response = try await networkService.mutate(request: request)
        let favouriteFeedingPoint = FavouriteFeedingPoint(
            feedingPointId: response.feedingPointId,
            isFavorite: true
        )

        innerChangedFavoriteFeedingPoint.send(favouriteFeedingPoint)
        updateFavoriteFeedingPoints { favoriteFeedingPoints in
            var favoriteFeedingPoints = favoriteFeedingPoints
            favoriteFeedingPoints.append(response)
            return favoriteFeedingPoints
        }

        return favouriteFeedingPoint
    }

    @discardableResult
    func delete(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard
            let feedingPointIndex = innerFavoriteFeedingPoints.value.firstIndex(
                where: { $0.feedingPointId == identifier }
            )
        else {
            throw "[FavoritesService] Feeding point cannot be deleted from the Favorites.".asBaseError()
        }

        let favourite = innerFavoriteFeedingPoints.value[feedingPointIndex]
        let request: Request<Favourite> = .delete(favourite)
        let response = try await networkService.mutate(request: request)
        let deletedFavoriteFeedingPoint = FavouriteFeedingPoint(
            feedingPointId: response.feedingPointId,
            isFavorite: false
        )

        innerChangedFavoriteFeedingPoint.send(deletedFavoriteFeedingPoint)
        updateFavoriteFeedingPoints { favoriteFeedingPoints in
            var favoriteFeedingPoints = favoriteFeedingPoints
            favoriteFeedingPoints.remove(at: feedingPointIndex)
            return favoriteFeedingPoints
        }

        return deletedFavoriteFeedingPoint
    }
}

private extension FavoritesService {
    func updateFavoriteFeedingPoints(_ modify: ([Favourite]) -> [Favourite]) {
        let favoriteFeedingPoints = innerFavoriteFeedingPoints.value
        let modifiedFeedingPoints = modify(favoriteFeedingPoints)
        innerFavoriteFeedingPoints.send(modifiedFeedingPoints)
    }
}
