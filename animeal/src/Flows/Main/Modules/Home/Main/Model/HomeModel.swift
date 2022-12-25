import Foundation
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore

final class HomeModel: HomeModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder
    private let context: Context
    private var cashedFeedingPoints: [FeedingPoint] = []
    private let mapper: FeedingPointMappable

    // MARK: - Initialization
    init(
        context: Context = AppDelegate.shared.context,
        mapper: FeedingPointMappable = FeedingPointMapper()
    ) {
        self.context = context
        self.mapper = mapper
    }

    // MARK: - Requests
    func fetchFeedingPoints(_ completion: (([FeedingPoint]) -> Void)?) {
        context.networkService.query(request: .list(animeal.FeedingPoint.self)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let points):
                let feedingPoints = points.map { point in
                    self.mapper.mapFeedingPoint(point, feeding: false)
                }
                self.cashedFeedingPoints = feedingPoints
                DispatchQueue.main.async {
                    completion?(self.applyFilter(self.cashedFeedingPoints))
                }
            case .failure:
                // TODO: Add error handling here
                break
            }
        }
    }

    func fetchFilterItems(_ completion: (([FilterItem]) -> Void)?) {
        completion?([
            FilterItem(
                title: L10n.Segment.dogs,
                identifier: .dogs,
                isSelected: selectedFilter == .dogs
            ),
            FilterItem(
                title: L10n.Segment.cats,
                identifier: .cats,
                isSelected: selectedFilter == .cats
            )
        ])
    }

    func proceedFilter(_ identifier: HomeModel.FilterItemIdentifier) {
        context.defaultsService.write(key: Filter.selectedId, value: identifier.rawValue)
    }

    func proceedFeedingPointSelection(_ identifier: String, completion: (([FeedingPoint]) -> Void)?) {
        let modifiedPoints = cashedFeedingPoints.map { point in
            FeedingPoint(
                identifier: point.identifier,
                isSelected: point.identifier == identifier,
                location: point.location,
                pet: point.pet,
                hungerLevel: point.hungerLevel
            )
        }
        cashedFeedingPoints = modifiedPoints
        completion?(self.applyFilter(self.cashedFeedingPoints))
    }

    func fetchFeedingAction(request: HomeModel.FeedingActionRequest) -> HomeModel.FeedingAction {
        switch request {
        case .cancelFeeding:
            return .init(
                title: L10n.Feeding.Alert.cancelFeeding,
                actions: [
                    .init(title: L10n.Action.no, style: .inverted),
                    .init(title: L10n.Action.ok, style: .accent)
                ]
            )
        case .autoCancelFeeding:
            return .init(
                title: L10n.Feeding.Alert.feedingTimerOver,
                actions: [
                    .init(title: L10n.Action.gotIt, style: .accent)
                ]
            )
        }
    }

    func processCancelFeeding() {
        // TODO: Handle cancel feeding action here
        print("[TODO] Cancel feeding action not handlet yet")
    }

    func fetchFeedingPoint(_ pointId: String) async throws -> HomeModel.FeedingPoint {
        let request = Request<animeal.FeedingPoint>.get(animeal.FeedingPoint.self, byId: pointId)
        let result = try await context.networkService.query(request: request)
        if let point = result {
            return self.mapper.mapFeedingPoint(point, feeding: true)
        } else {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
    }
}

// MARK: Private API
private extension HomeModel {
    enum Filter: String, LocalStorageKeysProtocol {
        case selectedId = "selectedFilterId"
    }

    var selectedFilter: HomeModel.FilterItemIdentifier {
        let selectedId = context.defaultsService.value(key: Filter.selectedId) ?? 0
        return HomeModel.FilterItemIdentifier(rawValue: selectedId) ?? .dogs
    }

    func applyFilter(_ points: [FeedingPoint]) -> [FeedingPoint] {
        switch selectedFilter {
        case .dogs:
            return points.filter {
                $0.pet == .dogs
            }
        case .cats:
            return points.filter {
                $0.pet == .cats
            }
        }
    }
}
