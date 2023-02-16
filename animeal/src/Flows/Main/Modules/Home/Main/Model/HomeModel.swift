import Foundation
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore

final class HomeModel: HomeModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder & UserProfileServiceHolder
    private let context: Context
    private var cachedFeedingPoints: [FeedingPoint] = []
    private var cachedFavouritesList: [Favourite] = []
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
    func fetchFeedingPoints() async throws -> [FeedingPoint] {
        do {
            await fetchFavorites()
            let points = try await context.networkService.query(request: .list(animeal.FeedingPoint.self))
            let feedingPoints = points.map { feedingPoint in
                let isFavorite = self.cachedFavouritesList.contains { fav in
                    fav.feedingPointId == feedingPoint.id
                }
                return mapper.mapFeedingPoint(feedingPoint, isFavorite: isFavorite)
            }
            cachedFeedingPoints = feedingPoints
            return applyFilter(cachedFeedingPoints)
        } catch {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
    }

    func fetchFavorites() async {
        let userId = context.profileService.getCurrentUser()?.userId ?? ""
        let fav = Favourite.keys
        let predicate = fav.userId == userId
        do {
            let favorites = try await context.networkService.query(request: .list(Favourite.self, where: predicate))
            cachedFavouritesList = favorites
        } catch {
            print(error.localizedDescription)
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
                hungerLevel: point.hungerLevel,
                isFavorite: point.isFavorite
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
    func processCancelFeeding() async throws -> FeedingResponse {
        do {
            let feedingId = snapshotStore.snaphot?.pointId ?? .empty
            let result = try await context.networkService.query(
                request: .customMutation(CancelFeedingMutation(id: feedingId))
            )
            snapshotStore.removeStoredSnaphot()
            return FeedingResponse(
                feedingPoint: result.cancelFeeding,
                feedingStatus: .none)
        } catch {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
    }

    func processStartFeeding(feedingPointId: String) async throws -> FeedingResponse {
        do {
            let result = try await context.networkService.query(
                request: .customMutation(StartFeedingMutation(id: feedingPointId))
            )
            snapshotStore.save(result.startFeeding, date: Date.now)
            return FeedingResponse(
                feedingPoint: result.startFeeding,
                feedingStatus: .progress)
        } catch {
            throw L10n.Feeding.Alert.feedingPointHasBooked.asBaseError()
        }
    }

    func processFinishFeeding(imageKeys: [String]) async throws -> FeedingResponse {
        do {
            let feedingId = snapshotStore.snaphot?.pointId ?? .empty
            let result = try await context.networkService.query(
                request: .customMutation(FinishFeedingMutation(id: feedingId, images: imageKeys))
            )
            snapshotStore.removeStoredSnaphot()
            return FeedingResponse(
                feedingPoint: result.finishFeeding,
                feedingStatus: .none
            )
        } catch {
            throw L10n.Errors.somthingWrong.asBaseError()
        }
    }

    func fetchFeedingPoint(_ pointId: String) async throws -> HomeModel.FeedingPoint {
        let request = Request<animeal.FeedingPoint>.get(animeal.FeedingPoint.self, byId: pointId)
        let result = try await context.networkService.query(request: request)
        if let point = result {
            let isFavorite = self.cachedFavouritesList.contains { fav in
                fav.feedingPointId == pointId
            }
            return self.mapper.mapFeedingPoint(point, isFavorite: isFavorite)
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
