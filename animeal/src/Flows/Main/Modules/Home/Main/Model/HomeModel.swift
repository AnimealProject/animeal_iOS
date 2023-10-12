import Foundation
import Services
import Combine
import Amplify

final class HomeModel: HomeModelProtocol {
    typealias Context = DefaultsServiceHolder
                        & NetworkServiceHolder
                        & UserProfileServiceHolder
                        & FeedingPointsServiceHolder
    private let context: Context
    private var cachedFeedingPoints: [FeedingPoint] = []
    private var cachedFavouritesList: [Favourite] = []
    private let mapper: FeedingPointMappable
    private let snapshotStore: FeedingSnapshotStorable
    private var cancellables = Set<AnyCancellable>()

    var onFeedingPointChange: (([HomeModel.FeedingPoint]) -> Void)?

    // MARK: - Initialization
    init(
        context: Context = AppDelegate.shared.context,
        mapper: FeedingPointMappable = FeedingPointMapper(),
        snapshotStore: FeedingSnapshotStorable = FeedingSnapshotStore()
    ) {
        self.context = context
        self.mapper = mapper
        self.snapshotStore = snapshotStore

        subscribeForFeedingPointChangeEvents()
    }

    // MARK: - Requests
    func fetchFeedingPoints() async throws -> [FeedingPoint] {
        do {
            let points = try await context.feedingPointsService.fetchAll()
            let feedingPoints = points.map { point in
                mapper.mapFeedingPoint(point.feedingPoint, isFavorite: point.isFavorite)
            }
            cachedFeedingPoints = feedingPoints
            return applyFilter(cachedFeedingPoints)
        } catch {
            throw L10n.Errors.somthingWrong.asBaseError()
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

    func proceedFeedingPointSelection(_ identifier: String) -> [FeedingPoint] {
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
        return self.applyFilter(self.cachedFeedingPoints)
    }

    func fetchFeedingAction(request: HomeModel.FeedingActionRequest) -> HomeModel.FeedingAction {
        switch request {
        case .cancelFeeding:
            return .init(
                title: L10n.Feeding.Alert.cancelFeeding,
                actions: [
                    .init(title: L10n.Action.no, style: .inverted),
                    .init(title: L10n.Action.ok, style: .accent(.cancelFeeding))
                ]
            )
        case .autoCancelFeeding:
            return .init(
                title: L10n.Feeding.Alert.feedingTimerOver,
                actions: [
                    .init(title: L10n.Action.gotIt, style: .accent(.autoCancelFeeding))
                ]
            )
        case .cameraAccess:
            return .init(
                title: L10n.Feeding.Alert.grantCameraPermission,
                actions: [
                    .init(title: L10n.Action.no, style: .inverted),
                    .init(title: L10n.Action.openSettings, style: .accent(.cameraAccess))
                ])
        case .locationAccess:
            return .init(
                title: L10n.Feeding.Alert.grantLocationPermission,
                actions: [
                    .init(title: L10n.Action.noThanks, style: .inverted),
                    .init(title: L10n.Action.openSettings, style: .accent(.locationAccess))
                ])
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

    @discardableResult
    func processRejectFeeding() async throws -> FeedingResponse {
        do {
            let feedingId = snapshotStore.snaphot?.pointId ?? .empty
            guard let feeding = try await context.networkService.query(
                request: .get(Feeding.self, byId: feedingId)
            ) else {
                throw L10n.Errors.somthingWrong.asBaseError()
            }
            let result = try await context.networkService.query(
                request: .customMutation(
                    RejectFeedingMutation(
                        id: feedingId,
                        feeding: feeding
                    )
                )
            )
            snapshotStore.removeStoredSnaphot()
            return FeedingResponse(
                feedingPoint: result.rejectFeeding,
                feedingStatus: .none
            )
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

    func fetchActiveFeeding() async throws -> Feeding? {
        guard let userId = await context.profileService.getCurrentUser()?.username else {
            return nil
        }
        let userIdPredicate = QueryPredicateOperation(field: "userId", operator: .equals(userId))
        return try await context.networkService.query(
            request: .list(Feeding.self, where: userIdPredicate)
        ).first
    }

    /// Retrives selected filter type from the user defaults
    var selectedFilter: HomeModel.FilterItemIdentifier {
        let selectedId = context.defaultsService.value(key: Filter.selectedId) ?? 0
        return HomeModel.FilterItemIdentifier(rawValue: selectedId) ?? .dogs
    }

    /// fetchs cached feeding points from the service. returns the feeding points as per selected pet
    var savedFeedingPoints: [FeedingPoint] {
        let points = context.feedingPointsService.storedFeedingPoints
        let feedingPoints = points.map { point in
            mapper.mapFeedingPoint(point.feedingPoint, isFavorite: point.isFavorite)
        }
        cachedFeedingPoints = feedingPoints
        return applyFilter(cachedFeedingPoints)
    }
}

// MARK: Private API
private extension HomeModel {
    func subscribeForFeedingPointChangeEvents() {
        context.feedingPointsService.feedingPoints
            .sink { [weak self] result in
                guard let self else { return }
                let points = result.uniqueValues
                let feedingPoints = points.map { point in
                    self.mapper.mapFeedingPoint(point.feedingPoint, isFavorite: point.isFavorite)
                }
                self.cachedFeedingPoints = feedingPoints
                self.onFeedingPointChange?(self.applyFilter(self.cachedFeedingPoints))
            }
            .store(in: &cancellables)
    }

    enum Filter: String, LocalStorageKeysProtocol {
        case selectedId = "selectedFilterId"
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
