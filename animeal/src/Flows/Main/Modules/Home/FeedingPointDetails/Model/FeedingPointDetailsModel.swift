import Foundation
import Services
import Amplify
import CoreLocation
import Combine

final class FeedingPointDetailsModel: FeedingPointDetailsModelProtocol, FeedingPointDetailsDataStoreProtocol {
    // MARK: - Private properties
    private let mapper: FeedingPointDetailsModelMapperProtocol

    typealias Context = NetworkServiceHolder
                        & DataStoreServiceHolder
                        & UserProfileServiceHolder
                        & FeedingPointsServiceHolder
    private let context: Context
    private var cachedFeedingPoint: FullFeedingPoint?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - DataStore properties
    let feedingPointId: String
    var feedingPointLocation: CLLocationCoordinate2D {
        guard
            let latitude = cachedFeedingPoint?.feedingPoint.location.lat,
            let longitude = cachedFeedingPoint?.feedingPoint.location.lon
        else {
            return CLLocationCoordinate2D()
        }
        return  CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    // MARK: - Subscription Event
    var onFeedingPointChange: ((FeedingPointDetailsModel.PointContent) -> Void)?

    // MARK: - Initialization
    init(
        pointId: String,
        mapper: FeedingPointDetailsModelMapperProtocol = FeedingPointDetailsModelMapper(),
        context: Context = AppDelegate.shared.context
    ) {
        self.feedingPointId = pointId
        self.mapper = mapper
        self.context = context
        subscribeForFeedingPointChangeEvents()
    }

    func fetchFeedingPoint(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        let fullFeedingPoint = context.feedingPointsService.storedfeedingPoints.first { point in
            point.feedingPoint.id == self.feedingPointId
        }

        if let feedingPointModel = fullFeedingPoint {
            cachedFeedingPoint = fullFeedingPoint
            completion?(
                mapper.map(
                    feedingPointModel.feedingPoint,
                    isFavorite: feedingPointModel.isFavorite
                )
            )
        }
    }

    func mutateFavorite() async throws -> Bool {
        guard let feedingPoint = cachedFeedingPoint else {
            return false
        }
        if feedingPoint.isFavorite {
            try await context.feedingPointsService.deleteFromFavorites(byIdentifier: feedingPointId)
        } else {
            try await context.feedingPointsService.addToFavorites(byIdentifier: feedingPointId)
        }
        return true
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

    private func subscribeForFeedingPointChangeEvents() {
        self.context.feedingPointsService.feedingPoints
            .sink { [weak self] result in
                guard let self else { return }
                let points = result.uniqueValues
                let updatedFeeding = points.first {
                    $0.feedingPoint.id == self.feedingPointId
                }
                if let feedingPointModel = updatedFeeding {
                    self.cachedFeedingPoint = feedingPointModel
                    self.onFeedingPointChange?(self.mapper.map(
                        feedingPointModel.feedingPoint,
                        isFavorite: feedingPointModel.isFavorite
                    ))
                }
            }
            .store(in: &cancellables)
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
