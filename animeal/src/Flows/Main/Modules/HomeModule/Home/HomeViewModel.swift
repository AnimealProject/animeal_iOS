import Services
import Amplify

final class HomeViewModel: HomeViewModelLifeCycle, HomeViewInteraction, HomeViewState {
    // MARK: - Dependencies
    private let model: HomeModelProtocol
    private let locationService: LocationServiceProtocol
    private let feedingPointViewMapper: FeedingPointViewMappable
    private let segmentsViewMapper: FilterViewMappable
    private let coordinator: HomeCoordinatable

    // MARK: - State
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)?
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)?

    // MARK: - Initialization
    init(
        model: HomeModelProtocol,
        coordinator: HomeCoordinatable,
        locationService: LocationServiceProtocol = AppDelegate.shared.context.locationService,
        feedingPointViewMapper: FeedingPointViewMappable = FeedingPointViewMapper(),
        segmentsViewMapper: FilterViewMappable = SegmentedControlMapper()
    ) {
        self.model = model
        self.locationService = locationService
        self.feedingPointViewMapper = feedingPointViewMapper
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
            }
        case .tapFilterControl(let filterItemId):
            guard let itemIdentifier = HomeModel.FilterItemIdentifier(rawValue: filterItemId) else {
                logError("[APP] \(#function) no filter with \(filterItemId)")
                return
            }
            model.proceedFilter(itemIdentifier)
            fetchFeedingPoints()
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
