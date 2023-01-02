import Foundation
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore

final class HomeModel: HomeModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder
    private let context: Context
    private var cachedFeedingPoints: [FeedingPoint] = []
    private let mapper: FeedingPointMappable
    private let snapshotStore: FeedingSnapshotStorable

    // MARK: - Initialization
    init(
        context: Context = AppDelegate.shared.context,
        mapper: FeedingPointMappable = FeedingPointMapper(),
        snapshotStore: FeedingSnapshotStorable = FeedingSnapshotStore()
    ) {
        self.context = context
        self.mapper = mapper
        self.snapshotStore = snapshotStore
    }

    // MARK: - Requests
    func fetchFeedingPoints(_ completion: (([FeedingPoint]) -> Void)?) {
        context.networkService.query(request: .list(animeal.FeedingPoint.self)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let points):
                let feedingPoints = points.map { point in
                    self.mapper.mapFeedingPoint(point)
                }
                self.cachedFeedingPoints = feedingPoints.filter { point in point.hungerLevel != .mid }
                DispatchQueue.main.async {
                    completion?(self.applyFilter(self.cachedFeedingPoints))
                }
            case .failure:
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
        let modifiedPoints = cachedFeedingPoints.map { point in
            FeedingPoint(
                identifier: point.identifier,
                isSelected: point.identifier == identifier,
                location: point.location,
                pet: point.pet,
                hungerLevel: point.hungerLevel
            )
        }
        cachedFeedingPoints = modifiedPoints
        completion?(self.applyFilter(self.cachedFeedingPoints))
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

    func fetchFeedingSnapshot() -> FeedingSnapshot? {
        return snapshotStore.snaphot
    }

    @discardableResult
    func processCancelFeeding() async throws -> String {
        do {
            let feedingId = snapshotStore.snaphot?.pointId ?? .empty
            let result = try await context.networkService.query(request: .cancelFeeding(feedingId))
            snapshotStore.removeStoredSnaphot()
            return result.cancelFeeding
        } catch {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
    }

    func processStartFeeding(feedingPointId: String) async throws -> String {
        do {
            let result = try await context.networkService.query(request: .startFeeding(feedingPointId))
            snapshotStore.save(result.startFeeding, date: Date.now)
            return result.startFeeding
        } catch {
            throw L10n.Feeding.Alert.feedingPointHasBooked.asBaseError()
        }
    }

    func fetchFeedingPoint(_ pointId: String) async throws -> HomeModel.FeedingPoint {
        let request = Request<animeal.FeedingPoint>.get(animeal.FeedingPoint.self, byId: pointId)
        let result = try await context.networkService.query(request: request)
        if let point = result {
            return self.mapper.mapFeedingPoint(point)
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
