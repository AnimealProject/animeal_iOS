import Services
import Common
import CoreLocation
import Amplify

final class HomeViewModel: HomeViewModelLifeCycle, HomeViewInteraction, HomeViewState {
    // MARK: - Dependencies
    private let model: HomeModelProtocol
    private let locationService: LocationServiceProtocol
    private let feedingPointViewMapper: FeedingPointViewMappable
    private let segmentsViewMapper: FilterViewMappable
    private let feedingActionMapper: FeedingActionMapper
    private var coordinator: HomeCoordinatable & HomeCoordinatorEventHandlerProtocol
    private enum Constants {
        static let feedingCountdownTimer: TimeInterval = 3600
    }

    // MARK: - State
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)?
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)?
    var onRouteRequestHaveBeenPrepared: ((FeedingPointRouteRequest) -> Void)?
    var onFeedingActionHaveBeenPrepared: ((FeedingActionMapper.FeedingAction) -> Void)?
    var onErrorHaveBeenPrepared: ((String) -> Void)?

    // MARK: - Initialization
    init(
        model: HomeModelProtocol,
        coordinator: HomeCoordinatable & HomeCoordinatorEventHandlerProtocol,
        locationService: LocationServiceProtocol = AppDelegate.shared.context.locationService,
        feedingPointViewMapper: FeedingPointViewMappable = FeedingPointViewMapper(),
        feedingActionMapper: FeedingActionMapper = FeedingActionMapper(),
        segmentsViewMapper: FilterViewMappable = SegmentedControlMapper()
    ) {
        self.model = model
        self.locationService = locationService
        self.feedingPointViewMapper = feedingPointViewMapper
        self.feedingActionMapper = feedingActionMapper
        self.segmentsViewMapper = segmentsViewMapper
        self.coordinator = coordinator
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        fetchFeedingPoints()
        fetchFilterItems()
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: HomeViewActionEvent) {
        switch event {
        case .tapFeedingPoint(let pointId):
            model.proceedFeedingPointSelection(pointId) { [weak self] points in
                guard let self = self else { return }
                let viewItems = points.map { self.feedingPointViewMapper.mapFeedingPoint($0) }
                self.onFeedingPointsHaveBeenPrepared?(viewItems)
                self.coordinator.routeTo(.details(pointId))
                self.coordinator.feedingDidStartedEvent = { [weak self] event in
                    self?.onRouteRequestHaveBeenPrepared?(
                        .init(
                            feedingPointCoordinates: event.coordinates,
                            countdownTime: Constants.feedingCountdownTimer,
                            feedingPointId: event.identifier,
                            isUnfinishedFeeding: false
                        )
                    )
                }
            }
        case .tapFilterControl(let filterItemId):
            guard let itemIdentifier = HomeModel.FilterItemIdentifier(rawValue: filterItemId) else {
                logError("[APP] \(#function) no filter with \(filterItemId)")
                return
            }
            model.proceedFilter(itemIdentifier)
            fetchFeedingPoints()
        case .tapCancelFeeding:
            let action = model.fetchFeedingAction(request: .cancelFeeding)
            onFeedingActionHaveBeenPrepared?(feedingActionMapper.mapFeedingAction(action))
        case .autoCancelFeeding:
            let action = model.fetchFeedingAction(request: .autoCancelFeeding)
            onFeedingActionHaveBeenPrepared?(feedingActionMapper.mapFeedingAction(action))
        case .confirmCancelFeeding:
            Task { [weak self] in
                guard let self else { return }
                do {
                    try await self.model.processCancelFeeding()
                } catch {
                    logError("[APP] \(#function) failed to cancel feeding: \(error.localizedDescription)")
                }
                self.fetchFeedingPoints()
            }
        }
    }

    func fetchUnfinishedFeeding() {
        guard
            let snapshot = model.fetchFeedingSnapshot(),
            (Date.now - 3600) < snapshot.feedStartingDate
        else {
            return
        }
        Task { [weak self] in
            guard let self else { return }
            do {
                let feedingPoint = try await self.model.fetchFeedingPoint(snapshot.pointId)
                let pointItemView = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)
                // Update view with feedingPoint details
                self.onFeedingPointsHaveBeenPrepared?([pointItemView])
                // Request build route
                let timePassSinceFeedingStarted = Date.now - snapshot.feedStartingDate
                self.onRouteRequestHaveBeenPrepared?(
                    .init(
                        feedingPointCoordinates: pointItemView.coordinates,
                        countdownTime: Constants.feedingCountdownTimer - timePassSinceFeedingStarted,
                        feedingPointId: snapshot.pointId,
                        isUnfinishedFeeding: true
                    )
                )
            }
        }
    }

    func startFeeding(feedingPointId id: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let pointId = try await model.processStartFeeding(feedingPointId: id)
                let feedingPoint = try await self.model.fetchFeedingPoint(pointId)
                let pointItemView = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)
                self.onFeedingPointsHaveBeenPrepared?([pointItemView])
            } catch {
                self.onErrorHaveBeenPrepared?(error.localizedDescription)
            }
        }
    }
}

private extension HomeViewModel {
    func fetchFeedingPoints() {
        model.fetchFeedingPoints { [weak self] points in
            guard let self = self else { return }
            let viewItems = points.map { self.feedingPointViewMapper.mapFeedingPoint($0) }
            self.onFeedingPointsHaveBeenPrepared?(viewItems)
        }
    }

    func fetchFilterItems() {
        model.fetchFilterItems { [weak self] filterItems in
            guard let self = self else { return }
            let model = self.segmentsViewMapper.mapFilterModel(filterItems)
            self.onSegmentsHaveBeenPrepared?(model)
        }
    }
}
