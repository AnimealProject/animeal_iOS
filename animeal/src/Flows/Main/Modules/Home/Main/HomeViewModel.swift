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
    private var feedingStatus: FeedingResponse.Status = .none {
        didSet {
            self.onCurrentFeedingStateChanged?(feedingStatus == .progress)
        }
    }
    private enum Constants {
        static let feedingCountdownTimer: TimeInterval = 3600
    }

    // MARK: - State
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)?
    var onFeedingPointCameraMoveRequired: ((FeedingPointCameraMove) -> Void)?
    var onFeadingPointsZoomRequired: (([String]) -> Void)?
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)?
    var onRouteRequestHaveBeenPrepared: ((FeedingPointRouteRequest) -> Void)?
    var onFeedingActionHaveBeenPrepared: ((FeedingActionMapper.FeedingAction) -> Void)?
    var onFeedingHaveBeenCompleted: (() -> Void)?
    var onCurrentFeedingStateChanged: ((Bool) -> Void)?
    var onRequestToCamera: (() -> CameraAccessState)?
    var onCameraPermissionNativeRequired: (() -> Void)?
    var onCameraPermissionCustomRequired: (() -> Void)?
    var onLocationPermissionRequired: (() -> Void)?

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
    func setup() {
        coordinator.moveToFeedingPointEvent = { [weak self] in
            self?.handleMoveToFeedingPoint(pointId: $0)
        }

        coordinator.feedingDidStartedEvent = { [weak self] event in
            guard let self else { return }

            switch self.feedingStatus {
            case .progress:
                self.coordinator.displayAlert(
                    message: L10n.Feeding.Error.otherFeedingRunning
                )
            case .none:
                self.onRouteRequestHaveBeenPrepared?(
                    .init(
                        feedingPointCoordinates: event.coordinates,
                        countdownTime: Constants.feedingCountdownTimer,
                        feedingPointId: event.identifier,
                        isUnfinishedFeeding: false
                    )
                )
            }
        }
    }

    func load() {
        Task { [weak self] in
            guard let self else { return }
            let hasUnfinishedFeeding = await fetchUnfinishedFeeding()
            if !hasUnfinishedFeeding {
                self.fetchFeedingPoints(isInitialLoad: true)
            }
            self.fetchFilterItems()
            self.startFeedingPoinsEventsListener()
        }
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: HomeViewActionEvent) {
        switch event {
        case .tapFeedingPoints(let pointIds) where pointIds.count == 1:
            guard let pointId = pointIds.first else { return }
            handleTapFeedingPoint(pointId: pointId)
            onFeadingPointsZoomRequired?(pointIds)
        case .tapFeedingPoints(let pointIds):
            onFeadingPointsZoomRequired?(pointIds)
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
            handleRejectFeeding()
        case .confirmCancelFeeding:
            handleConfirmCancelFeeding()
        case .getCameraPermission:
            handleGetCameraPermission()
        case .getLocationPermission:
            handleGetLocationPermission()
        }
    }

    func fetchUnfinishedFeeding() async -> Bool {
        guard let activeFeeding = try? await model.fetchActiveFeeding() else {
            return false
        }
        do {
            let snapshotTimeDiff = model.fetchFeedingSnapshot()?.startingTimeDiff ?? NetTime.serverTimeDifference
            let timeDiff = snapshotTimeDiff - NetTime.serverTimeDifference
            let feedingPoint = try await model.fetchFeedingPoint(activeFeeding.feedingPointFeedingsId)
            let pointItemView = feedingPointViewMapper.mapFeedingPoint(feedingPoint)
            // Update view with feedingPoint details
            onFeedingPointsHaveBeenPrepared?([pointItemView])
            // Request build route
            let timePassSinceFeedingStarted = Date.now - activeFeeding.createdAt.foundationDate + timeDiff
            onRouteRequestHaveBeenPrepared?(
                .init(
                    feedingPointCoordinates: pointItemView.coordinates,
                    countdownTime: Constants.feedingCountdownTimer - timePassSinceFeedingStarted,
                    feedingPointId: activeFeeding.feedingPointFeedingsId,
                    isUnfinishedFeeding: true
                )
            )
            feedingStatus = .progress
            return true
        } catch {
            return false
        }
    }

    func refreshCurrentFeeding() {
        coordinator.displayActivityIndicator(waitUntil: { [weak self] in
            _ = await self?.fetchUnfinishedFeeding()
        })
    }

    func startFeeding(feedingPointId id: String) {
        coordinator.displayActivityIndicator(waitUntil: { [weak self] in
            guard let self else { return }

            let result = try await self.model.processStartFeeding(feedingPointId: id)
            let feedingPoint = try await self.model.fetchFeedingPoint(result.feedingPoint)

            switch self.locationService.locationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                break
            case .denied, .restricted, .notDetermined:
                let action = self.model.fetchFeedingAction(request: .locationAccess)
                self.onFeedingActionHaveBeenPrepared?(self.feedingActionMapper.mapFeedingAction(action))
            default:
                break
            }

            switch self.onRequestToCamera?() ?? .denied {
            case .authorized:
                break
            case .notDetermined:
                self.onCameraPermissionNativeRequired?()
            case .denied:
                let action = self.model.fetchFeedingAction(request: .cameraAccess)
                self.onFeedingActionHaveBeenPrepared?(self.feedingActionMapper.mapFeedingAction(action))
            }

            let pointItemView = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)
            self.onFeedingPointsHaveBeenPrepared?([pointItemView])
            self.feedingStatus = result.feedingStatus
        }, completion: { [weak self] isSuccess in
            if !isSuccess {
                self?.feedingStatus = .none
            }
        })
    }

    func finishFeeding(imageKeys: [String]) {
        let task = { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.processFinishFeeding(imageKeys: imageKeys)
                let feedingPoint = try await self.model.fetchFeedingPoint(result.feedingPoint)
                let pointItemView = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)
                self.onFeedingPointsHaveBeenPrepared?([pointItemView])
                self.feedingStatus = result.feedingStatus
                self.onFeedingHaveBeenCompleted?()
                self.coordinator.routeTo(.feedingComplete)
            } catch {
                self.coordinator.displayAlert(message: error.localizedDescription)
            }
        }
        coordinator.displayActivityIndicator(waitUntil: task)
    }
}

private extension HomeViewModel {
    func fetchFeedingPoints(isInitialLoad: Bool = false) {
        let task = { [weak self] in
            guard let self else { return }
            let points = try await self.model.fetchFeedingPoints()
            let viewItems = points.map { self.feedingPointViewMapper.mapFeedingPoint($0) }
            self.onFeedingPointsHaveBeenPrepared?(viewItems)
        }
        if isInitialLoad {
            Task { try await task() }
        } else {
            coordinator.displayActivityIndicator(waitUntil: task)
        }
    }

    func startFeedingPoinsEventsListener() {
        model.onFeedingPointChange = { [weak self] feedingPoints in
            guard let self else { return }
            guard self.feedingStatus != .progress else { return }
            let viewItems = feedingPoints.map {
                self.feedingPointViewMapper.mapFeedingPoint($0)
            }
            DispatchQueue.main.async {
                self.onFeedingPointsHaveBeenPrepared?(viewItems)
            }
        }
    }

    func fetchFilterItems() {
        model.fetchFilterItems { [weak self] filterItems in
            guard let self = self else { return }
            let model = self.segmentsViewMapper.mapFilterModel(filterItems)
            self.onSegmentsHaveBeenPrepared?(model)
        }
    }

    func handleConfirmCancelFeeding() {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.processCancelFeeding()
                self.feedingStatus = result.feedingStatus
            } catch {
                logError("[APP] \(#function) failed to cancel feeding: \(error.localizedDescription)")
            }
            let points = try await self.model.fetchFeedingPoints()
            let viewItems = points.map { self.feedingPointViewMapper.mapFeedingPoint($0) }
            self.onFeedingPointsHaveBeenPrepared?(viewItems)
        }
    }
    
    func handleGetCameraPermission() {
        onCameraPermissionCustomRequired?()
    }
    
    func handleGetLocationPermission() {
        onLocationPermissionRequired?()
    }

    func handleRejectFeeding() {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.processRejectFeeding()
                self.feedingStatus = result.feedingStatus
            } catch {
                logError("[APP] \(#function) failed to reject feeding: \(error.localizedDescription)")
            }
            let points = try await self.model.fetchFeedingPoints()
            let viewItems = points.map { self.feedingPointViewMapper.mapFeedingPoint($0) }
            let action = self.model.fetchFeedingAction(request: .autoCancelFeeding)
            self.onFeedingActionHaveBeenPrepared?(self.feedingActionMapper.mapFeedingAction(action))
            self.onFeedingPointsHaveBeenPrepared?(viewItems)
        }
    }

    func proceedFeedingPointSelection(pointId: String) {
        let points = model.proceedFeedingPointSelection(pointId)
        let viewItems = points.map {
            feedingPointViewMapper.mapFeedingPoint($0)
        }
        onFeedingPointsHaveBeenPrepared?(viewItems)
        coordinator.routeTo(.details(pointId))
    }

    func handleTapFeedingPoint(pointId: String) {
        switch feedingStatus {
        case .progress:
            coordinator.routeTo(.attachPhoto(pointId))
            coordinator.feedingDidFinishEvent = { [weak self] event in
                self?.finishFeeding(imageKeys: event)
            }
        case .none:
            proceedFeedingPointSelection(pointId: pointId)
        }
    }

    func handleMoveToFeedingPoint(pointId: String) {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            let feedingPoint = try await self.model.fetchFeedingPoint(pointId)
            let viewItem = self.feedingPointViewMapper.mapFeedingPoint(feedingPoint)

            do { // change filter for requested pet
                self.model.proceedFilter({
                    switch feedingPoint.pet {
                    case .cats: return .cats
                    case .dogs: return .dogs
                    }
                }())
                self.fetchFilterItems()
            }

            self.proceedFeedingPointSelection(pointId: pointId)
            self.onFeedingPointCameraMoveRequired?(
                .init(feedingPointCoordinate: viewItem.coordinates)
            )
        }
    }
}
