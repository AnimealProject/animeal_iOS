import Foundation
import Services
import Amplify

final class FeedingPointDetailsModel: FeedingPointDetailsModelProtocol, FeedingPointDetailsDataStoreProtocol {
    // MARK: - Private properties
    private let mapper: FeedingPointDetailsModelMapperProtocol

    typealias Context = NetworkServiceHolder & DataStoreServiceHolder & UserProfileServiceHolder
    private let context: Context

    // MARK: - DataStore properties
    let feedingPointId: String

    var relatedFavoritePoint: Favourite?
    var feedingPoint: FeedingPoint?

    // MARK: - Initialization
    init(
        pointId: String,
        mapper: FeedingPointDetailsModelMapperProtocol = FeedingPointDetailsModelMapper(),
        context: Context = AppDelegate.shared.context
    ) {
        self.feedingPointId = pointId
        self.mapper = mapper
        self.context = context
    }

    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        context.networkService.query(request: .get(FeedingPoint.self, byId: feedingPointId)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let point):
                guard let point = point else {
                    return
                }
                self.feedingPoint = point
                Task {
                    await self.fetchFavorites()
                    DispatchQueue.main.async {
                        completion?(
                            self.mapper.map(
                                point,
                                isFavorite: self.relatedFavoritePoint != nil
                            )
                        )
                    }
                }
            case .failure(let error):
                // TODO: Handele error
                print(error)
            }
        }
    }

    func mutateFavorite(completion: ((Bool) -> Void)?) {
        guard let feedingPoint = feedingPoint, let userId = context.profileService.getCurrentUser()?.userId else {
            completion?(false)
            return
        }

        var request: Request<Favourite>
        if let favoritePoint = relatedFavoritePoint {
            request = .delete(favoritePoint)
        } else {
            let favouritePoint = Favourite(
                userId: userId,
                feedingPointId: feedingPoint.id,
                feedingPoint: feedingPoint
            )
            request = .create(favouritePoint)
        }
        context.networkService.mutate(request: request) { event in
            switch event {
            case .success:
                DispatchQueue.main.async {
                    completion?(true)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }

    private func fetchFavorites() async {
        let userId = context.profileService.getCurrentUser()?.userId ?? ""
        let fav = Favourite.keys
        let predicate = fav.userId == userId
        do {
            let favorites = try await context.networkService.query(request: .list(Favourite.self, where: predicate))
            if let identifier = self.feedingPoint?.id {
                self.relatedFavoritePoint = favorites.first { fav in
                    fav.feedingPoint.id == identifier
                }
            }
        } catch {
            logError(error.localizedDescription)
        }
    }

    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?) {
        context.dataStoreService.downloadData(
            key: key,
            options: .init(accessLevel: .guest)
        ) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion?(data)
                }
            case .failure(let error):
                // TODO: Handele error
                print(error.localizedDescription)
            }
        }
    }
}

extension FeedingPointDetailsModel {
    struct PointContent {
        let content: Content
        let action: Action
    }

    struct Content {
        let header: Header
        let description: Description
        let status: Status
        let feeders: [Feeder]
        let isFavorite: Bool
    }

    struct Feeder {
        let name: String
        let lastFeeded: String
    }

    struct Header {
        let cover: String?
        let title: String
    }

    struct Description {
        let text: String
    }

    struct Action {
        let identifier: String
        let title: String
        let isEnabled: Bool
    }

    enum Status {
        case success(String)
        case attention(String)
        case error(String)
    }
}
