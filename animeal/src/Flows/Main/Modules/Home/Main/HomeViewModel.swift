import Services
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

    // MARK: - State
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)?
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)?
    var onRouteRequestHaveBeenPrepared: ((CLLocationCoordinate2D) -> Void)?
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
                self.coordinator.feedingDidStartedEvent = { event in
                    Task {
                        do {
                            let feedingPoint = try await self.model.fetchFeedingPoint(event.identifier)
                            DispatchQueue.main.async {
                                let pointItemView = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)
                                // Update view with feedingPoint details
                                self.onFeedingPointsHaveBeenPrepared?([pointItemView])
                                // Request build route
                                self.onRouteRequestHaveBeenPrepared?(pointItemView.coordinates)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.onErrorHaveBeenPrepared?(error.localizedDescription)
                                self.fetchFeedingPoints()
                            }
                        }
                    }
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
            load()
            model.processCancelFeeding()
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
