import Services
import Common
import CoreLocation
import Amplify

final class HomeViewModel: HomeViewModelLifeCycle, HomeViewInteraction, HomeViewState {
    // MARK: - Dependencies
    private let model: HomeModelProtocol
    private let cameraService: CameraServiceProtocol
    private let locationService: LocationServiceProtocol
    private let userProfileService: UserProfileServiceProtocol
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
        static let minimumZoomLevel: Double = 12.0
        static let bufferFactor: Double = 1.5
    }

    private var currentBounds: BoundsInput?
    private var loadedRegion: BoundsInput?
    private var isFetchingFeedingPoints = false

    // MARK: - State
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)?
    var onFeedingPointCameraMoveRequired: ((FeedingPointCameraMove) -> Void)?
    var onFeadingPointsZoomRequired: (([String]) -> Void)?
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)?
    var onRouteRequestHaveBeenPrepared: ((FeedingPointRouteRequest) -> Void)?
    var onFeedingActionHaveBeenPrepared: ((FeedingActionMapper.FeedingAction) -> Void)?
    var onFeedingHaveBeenCompleted: (() -> Void)?
    var onCurrentFeedingStateChanged: ((Bool) -> Void)?
    var onCameraPermissionCustomRequired: (() -> Void)?
    var onLocationPermissionRequired: (() -> Void)?

    // MARK: - Initialization
    init(
        model: HomeModelProtocol,
        coordinator: HomeCoordinatable & HomeCoordinatorEventHandlerProtocol,
        cameraService: CameraServiceProtocol = AppDelegate.shared.context.cameraService,
        locationService: LocationServiceProtocol = AppDelegate.shared.context.locationService,
        userProfileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService,
        feedingPointViewMapper: FeedingPointViewMappable = FeedingPointViewMapper(),
        feedingActionMapper: FeedingActionMapper = FeedingActionMapper(),
        segmentsViewMapper: FilterViewMappable = SegmentedControlMapper()
    ) {
        self.model = model
        self.cameraService = cameraService
        self.locationService = locationService
        self.userProfileService = userProfileService
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
            _ = await fetchUnfinishedFeeding()
            self.fetchFilterItems()
            self.startFeedingPoinsEventsListener()
        }
    }

    func requestLocationPermission() {
        self.locationService.requestLocationAuthorization(mode: .onlyInUse)
    }

    // MARK: - Interaction
    func handleMapCameraIdle(bounds: BoundsInput, zoom: Double) {
        guard zoom >= Constants.minimumZoomLevel else { return }
        currentBounds = bounds
        guard !(loadedRegion?.contains(bounds) ?? false), !isFetchingFeedingPoints else { return }
        let fetchBounds = bounds.expanded(by: Constants.bufferFactor)
        isFetchingFeedingPoints = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.isFetchingFeedingPoints = false }
            do {
                let points = try await self.model.fetchFeedingPoints(bounds: fetchBounds)
                self.loadedRegion = fetchBounds
                let viewItems = self.feedingPointViewMapper.mapFeedingPoints(points)
                self.onFeedingPointsHaveBeenPrepared?(viewItems)
            } catch {
                logError("[HomeViewModel] Failed to fetch feeding points: \(error.localizedDescription)")
            }
        }
    }

    func handleActionEvent(_ event: HomeViewActionEvent) {
        switch event {
        case .tapFeedingPoints(let pointIds):
            if let firstPointId = pointIds.first {
                handleTapFeedingPoint(pointId: firstPointId)
            }
            onFeadingPointsZoomRequired?(pointIds)
        case .tapFilterControl(let filterItemId):
            guard let itemIdentifier = HomeModel.FilterItemIdentifier(rawValue: filterItemId) else {
                logError("[APP] \(#function) no filter with \(filterItemId)")
                return
            }
            model.proceedFilter(itemIdentifier)
            fetchFeedingPointsWithCurrentBounds()
        case .tapCancelFeeding:
            let action = model.fetchFeedingAction(request: .cancelFeeding)
            onFeedingActionHaveBeenPrepared?(feedingActionMapper.mapFeedingAction(action))
        case .autoCancelFeeding:
            handleFeedingExpiration()
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
            let creationDate = activeFeeding.createdAt.foundationDate
            model.updateFeedingSnapshot(id: activeFeeding.feedingPointFeedingsId, date: creationDate)

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
                    feedingPointCoordinates: pointItemView.originalCoordinates,
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
        coordinator.displayActivityIndicator { [weak self] in
            _ = await self?.fetchUnfinishedFeeding()
        }
    }

    func startFeeding(feedingPointId id: String) {
        coordinator.displayActivityIndicator(waitUntil: { [weak self] in
            guard let self else { return }

            let result = try await self.model.processStartFeeding(feedingPointId: id)
            let feedingPoint = try await self.model.fetchFeedingPoint(result.feedingPoint)

            let isCameraGranted = self.cameraService.grantCameraPermission {
                let action = self.model.fetchFeedingAction(request: .cameraAccess)
                self.onFeedingActionHaveBeenPrepared?(self.feedingActionMapper.mapFeedingAction(action))
            }
            if !isCameraGranted {
                logWarning(
                    "[Camera] Permission not granted, status: \(self.cameraService.cameraAuthorizationStatus.rawValue)"
                )
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

                if let bounds = self.currentBounds {
                    try await self.applyFeedingPointsRefresh(bounds: bounds)
                }
                self.feedingStatus = result.feedingStatus
                self.onFeedingHaveBeenCompleted?()

                let userAttributes = try await self.userProfileService.fetchUserAttributes()
                let trusted = userAttributes.first { attribute in
                    attribute.key == .custom("trusted")
                }?.value

                if trusted == "true" {
                    self.coordinator.routeTo(.feedingTrustedComplete)
                } else {
                    self.coordinator.routeTo(.feedingComplete)
                }
            } catch {
                self.coordinator.displayAlert(message: error.localizedDescription)
            }
        }
        coordinator.displayActivityIndicator(waitUntil: task)
    }

    /// Checks if the selected filter type is same as recorded in user defaults. If Yes no need to update. If No update.
    /// - Parameter selection: selected filter type. used to compare this with the selection recorded in user defaults.
    func updateSelectionIfNeeded(for selection: HomeModel.FilterItemIdentifier) {
        guard selection != model.selectedFilter else { return }
        let feedingPoints = model.savedFeedingPoints
        update(feedingPoints)
    }
}

private extension HomeViewModel {
    func fetchFeedingPointsWithCurrentBounds() {
        guard let bounds = currentBounds else { return }
        fetchFeedingPoints(bounds: bounds)
    }

    func fetchFeedingPoints(bounds: BoundsInput) {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            try await self.applyFeedingPointsRefresh(bounds: bounds)
        }
    }

    func applyFeedingPointsRefresh(bounds: BoundsInput) async throws {
        let fetchBounds = bounds.expanded(by: Constants.bufferFactor)
        let points = try await model.fetchFeedingPoints(bounds: fetchBounds)
        loadedRegion = fetchBounds
        let viewItems = feedingPointViewMapper.mapFeedingPoints(points)
        onFeedingPointsHaveBeenPrepared?(viewItems)
    }

    func startFeedingPoinsEventsListener() {
        model.onFeedingPointChange = { [weak self] feedingPoints in
            guard let self else { return }
            self.update(feedingPoints)
        }
    }

    /// update the filtered feeding points in map. as well as selected segemented bar
    /// - Parameter feedingPoints: feeding points fetched from the model
    func update(_ feedingPoints: [HomeModel.FeedingPoint]) {
        guard self.feedingStatus != .progress else { return }
        let viewItems = feedingPointViewMapper.mapFeedingPoints(feedingPoints)
        DispatchQueue.main.async {
            self.fetchFilterItems()
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

    func handleConfirmCancelFeeding() {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.processCancelFeeding()
                self.feedingStatus = result.feedingStatus
            } catch {
                logError("[APP] \(#function) failed to cancel feeding: \(error.localizedDescription)")
            }
            if let bounds = self.currentBounds {
                try await self.applyFeedingPointsRefresh(bounds: bounds)
            }
        }
    }

    func handleGetCameraPermission() {
        onCameraPermissionCustomRequired?()
    }

    func handleGetLocationPermission() {
        onLocationPermissionRequired?()
    }

    func handleFeedingExpiration() {
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.model.processFeedingExpiration()
                self.feedingStatus = result.feedingStatus
            } catch {
                logError("[APP] \(#function) failed to reject feeding: \(error.localizedDescription)")
            }
            if let bounds = self.currentBounds {
                try await self.applyFeedingPointsRefresh(bounds: bounds)
            }
            let action = self.model.fetchFeedingAction(request: .autoCancelFeeding)
            self.onFeedingActionHaveBeenPrepared?(self.feedingActionMapper.mapFeedingAction(action))
        }
    }

    func proceedFeedingPointSelection(pointId: String) {
        let points = model.proceedFeedingPointSelection(pointId)
        let viewItems = feedingPointViewMapper.mapFeedingPoints(points)
        onFeedingPointsHaveBeenPrepared?(viewItems)
        coordinator.routeTo(.details(pointId))
    }

    func handleTapFeedingPoint(pointId: String) {
        // Check if user is in guest mode
        let userValidationModel = userProfileService.getCurrentUserValidationModel()
        if userValidationModel.userMode == .guest {
            coordinator.presentGuestAlert(
                onRegister: { [weak self] in
                    guard let self = self else { return }
                    self.coordinator.dismissGuestAlert(animated: true) {
                        self.coordinator.needsAuthenticationEvent?()
                    }
                },
                onDismiss: { [weak self] in
                    self?.coordinator.dismissGuestAlert(animated: true, completion: nil)
                }
            )
            return
        }

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
