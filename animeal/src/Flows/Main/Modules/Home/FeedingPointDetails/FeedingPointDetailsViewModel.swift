import Foundation
import CoreLocation
import Common
import UIComponents
import Services

final class FeedingPointDetailsViewModel: FeedingPointDetailsViewModelLifeCycle,
                                          FeedingPointDetailsViewInteraction,
                                          FeedingPointDetailsViewState {
    // MARK: - Dependencies
    private let model: (FeedingPointDetailsModelProtocol & FeedingPointDetailsDataStoreProtocol)
    private let coordinator: FeedingPointCoordinatable
    private let contentMapper: FeedingPointDetailsViewMappable
    private let locationService: LocationServiceProtocol

    // MARK: - State
    var onContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem) -> Void)?
    var onFeedingHistoryHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointFeeders) -> Void)?
    var onMediaContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointMediaContent) -> Void)?
    var onModeratorsHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointModerators) -> Void)?
    var onFavoriteMutationFailed: (() -> Void)?
    var onFavoriteMutation: ((Bool) -> Void)?
    var onRequestLocationAccess: (() -> Void)?
    var historyInitialized = false
    var moderatorsInitialized = false

    // TODO: Move this strange logic to model
    let isOverMap: Bool
    private var shouldShowOnMap = true
    private let favoriteState: AsyncValue<Bool>
    var showOnMapAction: ButtonView.Model? {
        if isOverMap { return .none }

        if !shouldShowOnMap { return .none }

        return ButtonView.Model(
            identifier: UUID().uuidString,
            viewType: TextButtonView.self,
            title: L10n.Action.showOnMap,
            accessibilityIdentifier: AccessibilityID.FeedingPoint.showOnMapButton
        )
    }
    private var allModerators: [FeedingPointDetailsModel.Moderator] = []
    private var isModeratorsExpanded = true
    private var didRequestAllModerators = false
    let shimmerScheduler = ShimmerViewScheduler()

    // MARK: - Initialization
    init(
        isOverMap: Bool,
        model: (FeedingPointDetailsModelProtocol & FeedingPointDetailsDataStoreProtocol),
        locationService: LocationServiceProtocol = AppDelegate.shared.context.locationService,
        contentMapper: FeedingPointDetailsViewMappable,
        coordinator: FeedingPointCoordinatable
    ) {
        self.isOverMap = isOverMap
        self.model = model
        self.contentMapper = contentMapper
        self.coordinator = coordinator
        self.locationService = locationService
        self.favoriteState = AsyncValue<Bool>(false)
        favoriteState.onConfirmed = { [weak self] isFavorite in self?.onFavoriteMutation?(isFavorite) }
        favoriteState.onReverted = { [weak self] in self?.onFavoriteMutationFailed?() }
        setup()
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        model.fetchFeedingPoint { [weak self] content in
            DispatchQueue.main.async {
                self?.updateContent(content)
            }
        }
        model.fetchFeedingHistory { [weak self] content in
            DispatchQueue.main.async {
                self?.historyInitialized = true
                self?.updateFeedingHistoryContent(content)
            }
        }
        model.onModeratorsChange = { [weak self] moderators in
            DispatchQueue.main.async {
                self?.setModerators(moderators)
                self?.updateModeratorsContent()
            }
        }
        model.onFeedingPointChange = { [weak self] content, mutateFavorites in
            DispatchQueue.main.async {
                guard !mutateFavorites else { return }
                self?.updateContent(content)
            }
        }
    }

    private func loadMediaContent(_ key: String?) {
        guard let key = key else { return }
        model.fetchMediaContent(key: key) { [weak self] content in
            if let mediaContent = self?.contentMapper.mapFeedingPointMediaContent(content) {
                DispatchQueue.main.async {
                    self?.onMediaContentHaveBeenPrepared?(mediaContent)
                }
            }
        }
    }

    private func updateContent(_ modelContent: FeedingPointDetailsModel.PointContent) {
        favoriteState.update(confirmed: modelContent.content.isFavorite)
        shouldShowOnMap = modelContent.action.isEnabled
        loadMediaContent(modelContent.content.header.cover)
        onContentHaveBeenPrepared?(contentMapper.mapFeedingPoint(modelContent))
    }

    private func updateModeratorsContent() {
        guard !self.allModerators.isEmpty else {
            let mapped = contentMapper.mapModerators([], canShowMore: false, isExpanded: false, totalCount: 0)
            onModeratorsHaveBeenPrepared?(mapped)
            return
        }

        let moderatorsToDisplay: [FeedingPointDetailsModel.Moderator]
        let limit = ModeratorDisplayConstants.expandedLimit
        let totalCount = allModerators.count
        let hasMoreThanLimit = totalCount > limit
        if !isModeratorsExpanded {
            moderatorsToDisplay = []
        } else if didRequestAllModerators && hasMoreThanLimit {
            moderatorsToDisplay = allModerators
        } else {
            moderatorsToDisplay = Array(allModerators.prefix(limit))
        }

        let canShowMore = hasMoreThanLimit && isModeratorsExpanded && !didRequestAllModerators
        let mapped = contentMapper.mapModerators(
            moderatorsToDisplay,
            canShowMore: canShowMore,
            isExpanded: isModeratorsExpanded,
            totalCount: totalCount
        )
        onModeratorsHaveBeenPrepared?(mapped)
    }

    private func setModerators(_ moderators: [FeedingPointDetailsModel.Moderator]) {
        self.moderatorsInitialized = true
        self.allModerators = moderators
    }

    private func updateFeedingHistoryContent(_ modelContent: [FeedingPointDetailsModel.Feeder]) {
        let mappedContent = contentMapper.mapFeedingHistory(modelContent)
        onFeedingHistoryHaveBeenPrepared?(mappedContent)
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: FeedingPointEvent) {
        switch event {
        case .tapAction:
            switch self.locationService.locationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                coordinator.routeTo(
                    .feed(
                        FeedingPointFeedDetails(
                            identifier: model.feedingPointId,
                            coordinates: model.feedingPointLocation
                        )
                    )
                )

            case .denied, .restricted, .notDetermined:
                self.onRequestLocationAccess?()

            default:
                break
            }

        case .tapFavorite:
            favoriteState.mutate(to: !favoriteState.intended) { [weak self] desired in
                try await self?.model.setFavorite(desired)
                return desired
            }

        case .tapShowOnMap:
            coordinator.routeTo(
                .map(identifier: model.feedingPointId)
            )

        case .tapCancelLocationRequest:
            break

        case .tapShowMoreModerators:
            didRequestAllModerators = true
            updateModeratorsContent()

        case .tapToggleModeratorsVisibility:
            isModeratorsExpanded.toggle()
            didRequestAllModerators = false
            updateModeratorsContent()
        }
    }
}

private extension FeedingPointDetailsViewModel {
    enum ModeratorDisplayConstants {
        static let expandedLimit = 5
    }
}
