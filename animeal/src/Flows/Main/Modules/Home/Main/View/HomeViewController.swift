import UIKit
import AVFoundation
import Style
import UIComponents
import Common
@_spi(Experimental) import MapboxMaps

class HomeViewController: UIViewController {
    // MARK: - Private properties
    private var mapView: NavigationMapController!
    private let segmentedControl = FilledSegmentedControl()
    private lazy var feedControl: FeedingControlView = {
        let feedControl = FeedingControlView()
        feedControl.onCloseHandler = { [weak self] in
            self?.viewModel.handleActionEvent(.tapCancelFeeding)
        }
        feedControl.onTimerFinishHandler = { [weak self] in
            self?.viewModel.handleActionEvent(.autoCancelFeeding)
        }
        return feedControl
    }()
    private let userLocationButton = CircleButtonView.make()
    private var lacationButtonBottomAnchor: NSLayoutConstraint?
    private var styleURI: StyleURI {
        return UITraitCollection.current.userInterfaceStyle == .dark
        ? StyleURI.dark : StyleURI.streets
    }
    private var cameraAuthorizationStatus: AVAuthorizationStatus {
        get {
            return AVCaptureDevice.authorizationStatus(for: .video)
        }
    }

    // MARK: - Dependencies
    private let viewModel: HomeCombinedViewModel

    // MARK: - Initialization
    init(viewModel: HomeCombinedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        viewModel.load()

        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModel.refreshCurrentFeeding()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCameraEasePadding()
    }
}

extension HomeViewController: HomeViewModelOutput {
    func applyFeedingPoints(_ feedingPoints: [FeedingPointViewItem]) {
        mapView.setAnnotations(feedingPoints.reduce(into: [Annotation]()) { annotations, point in
            annotations.append(
                point.annotationModel.annotation(
                    at: point.coordinates
                )
            )
            
            if point.isSelected {
                annotations.append(
                    point.annotationModel.selectionAnnotation(
                        for: point.radius.converted(to: .meters).value,
                        at: point.coordinates
                    )
                )
            }
        })

        self.mapView.cameraAnimationQueue.append {
            self.easeToClosesFeedingPointOnce(feedingPoints)
        }
    }

    func applyFilter(_ filter: FilterModel) {
        segmentedControl.configure(filter.segmentedControlModel)
        segmentedControl.onTap = { [weak self] selectedSegmentIndex in
            self?.viewModel.handleActionEvent(.tapFilterControl(selectedSegmentIndex))
        }
    }
    
    func applyMapZoom(for pointsIds: [String]) {
        mapView.easeToAnnotations(
            mapView.getAnnotations(for: pointsIds),
            duration: 0
        )
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let mapView = mapView else { return }
        mapView.mapboxMap.loadStyleURI(styleURI)
    }
}

// MARK: - Private API
private extension HomeViewController {
    func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupMapView()

        let controlsContainer = UIStackView()
        controlsContainer.axis = .vertical
        controlsContainer.alignment = .center

        view.addSubview(controlsContainer.prepareForAutoLayout())
        controlsContainer.topAnchor ~= view.safeAreaLayoutGuide.topAnchor + 32
        controlsContainer.centerXAnchor ~= view.centerXAnchor
        controlsContainer.distribution = .fillProportionally

        controlsContainer.addArrangedSubview(segmentedControl)
        segmentedControl.widthAnchor ~= 226
        controlsContainer.addArrangedSubview(feedControl)
        feedControl.widthAnchor ~= 374
        toggleRouteAndTimer(isVisible: false)

        view.addSubview(userLocationButton.prepareForAutoLayout())
        userLocationButton.trailingAnchor ~= view.trailingAnchor - 30
        lacationButtonBottomAnchor = userLocationButton.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 38
        userLocationButton.isUserInteractionEnabled = false
        userLocationButton.onTap = { [weak self] _ in
            self?.mapView.easeToUserLocation()
        }
    }

    func bind() {
        viewModel.onFeedingPointsHaveBeenPrepared = { [weak self] points in
            self?.applyFeedingPoints(points)
        }
        
        viewModel.onFeadingPointsZoomRequired = { [weak self] points in
            self?.applyMapZoom(for: points)
        }

        viewModel.onFeedingPointCameraMoveRequired = { [weak self] move in
            self?.handleCameraMove(move)
        }

        viewModel.onSegmentsHaveBeenPrepared = { [weak self] model in
            self?.applyFilter(model)
        }

        viewModel.onRouteRequestHaveBeenPrepared = { [weak self] request in
            self?.handleRouteRequest(request)
        }

        viewModel.onFeedingActionHaveBeenPrepared = { [weak self] action in
            self?.handleFeedingAction(action)
        }

        viewModel.onFeedingHaveBeenCompleted = { [weak self] in
            self?.toggleRouteAndTimer(isVisible: false)
        }

        viewModel.onCurrentFeedingStateChanged = { [weak self] isInProgress in
            self?.toggleRouteAndTimer(isVisible: isInProgress)
        }
        
        viewModel.onRequestToCamera = { [weak self] in
            self?.cameraAuthorized() ?? .denied
        }
        
        viewModel.onCameraPermissionNativeRequired = { [weak self] in
            Task {
                await self?.requestCameraPermissionNative()
            }
        }
        
        viewModel.onCameraPermissionCustomRequired = { [weak self] in
            Task {
                await self?.openSettings()
            }
        }
        
        viewModel.onLocationPermissionRequired = { [weak self] in
            Task {
                await self?.openSettings()
            }
        }
    }

    func handleFeedingAction(_ action: FeedingActionMapper.FeedingAction) {
        let alertViewController = AlertViewController(title: action.title)

        action.actions.forEach { feedingAction in
            var actionHandler: (() -> Void)?
            switch feedingAction.style {
            case .inverted:
                actionHandler = {
                    alertViewController.dismiss(animated: true)
                }
            case .accent(let action):
                actionHandler = { [weak self] in
                    guard let self = self else { return }
                    if action == .cancelFeeding {
                        self.viewModel.handleActionEvent(.confirmCancelFeeding)
                    } else if action == .cameraAccess {
                        self.viewModel.handleActionEvent(.getCameraPermission)
                    } else if action == .locationAccess {
                        self.viewModel.handleActionEvent(.getLocationPermission)
                    }
                    alertViewController.dismiss(animated: true)
                }
            }
            alertViewController.addAction(
                AlertAction(
                    title: feedingAction.title,
                    style: feedingAction.style.alertActionStyle,
                    handler: actionHandler
                )
            )
        }
        self.present(alertViewController, animated: true)
    }

    func handleUpdatedRouteRequest(_ request: FeedingPointRouteRequest) {
        mapView.requestRoute(destination: request.feedingPointCoordinates) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if !request.isUnfinishedFeeding {
                    self.viewModel.startFeeding(feedingPointId: request.feedingPointId)
                }
            case .failure(let error):
                self.showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    func handleRouteRequest(_ request: FeedingPointRouteRequest) {
        mapView.requestRoute(destination: request.feedingPointCoordinates) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.feedControl.setTimerProvider(
                    FeedingTimerProvider(
                        configuration: .init(
                            timerInterval: 1,
                            countdownInterval: request.countdownTime
                        )
                    )
                )
                self.feedControl.startTimer()
                self.mapView.startLocationConsumer()

                self.handleLocationChange(
                    request.feedingPointCoordinates,
                    location: self.mapView.location.latestLocation?.location
                )
                self.mapView.didChangeLocation = { [weak self] location, updated in
                    if updated {
                        self?.handleLocationUpdated(request: request,
                                                    location: location)
                    } else {
                        self?.handleLocationChange(request.feedingPointCoordinates,
                                                   location: location)
                    }
                }
                if !request.isUnfinishedFeeding {
                    self.viewModel.startFeeding(feedingPointId: request.feedingPointId)
                }
            case .failure(let error):
                self.showErrorMessage(error.localizedDescription)
            }
        }
    }

    func showErrorMessage(_ description: String) {
        let alertViewController = AlertViewController(title: description)
        alertViewController.addAction(
            AlertAction(title: L10n.Action.ok, style: .accent) {
                alertViewController.dismiss(animated: true)
            }
        )
        present(alertViewController, animated: true)
    }

    func handleLocationChange(_ coordinates: CLLocationCoordinate2D, location: CLLocation?) {
        let feedingPointLocation = CLLocation(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )

        if let distance = location?.distance(from: feedingPointLocation) {
            feedControl.updateDistance(distance)
        }
    }
    
    func handleLocationUpdated(request: FeedingPointRouteRequest,
                               location: CLLocation?) {
        var updateRequest = FeedingPointRouteRequest(feedingPointCoordinates: request.feedingPointCoordinates,
                                           countdownTime: request.countdownTime,
                                           feedingPointId: request.feedingPointId,
                                           isUnfinishedFeeding: true)
        handleUpdatedRouteRequest(updateRequest)
        
        let feedingPointLocation = CLLocation(
            latitude: updateRequest.feedingPointCoordinates.latitude,
            longitude: updateRequest.feedingPointCoordinates.longitude
        )
        
        if let distance = location?.distance(from: feedingPointLocation) {
            feedControl.updateDistance(distance)
        }
    }

    func toggleRouteAndTimer(isVisible: Bool) {
        if !isVisible {
            feedControl.stopTimer()
            mapView.cancelRouteRequest()
        }
        segmentedControl.isHidden = isVisible
        feedControl.isHidden = !isVisible
    }

    func handleCameraMove(_ move: FeedingPointCameraMove) {
        mapView.easeToLocation(move.feedingPointCoordinate, duration: 0)
    }
    
    func cameraAuthorized() -> CameraAccessState {
        switch cameraAuthorizationStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
    
    func requestCameraPermissionNative() async {
        await AVCaptureDevice.requestAccess(for: .video)
    }
    
    func openSettings() async {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        await UIApplication.shared.open(url)
    }
}

// MARK: - MapBox helpers
private extension HomeViewController {
    func setupMapView() {
        mapView = NavigationMapController(frame: view.bounds)
        view.addSubview(mapView.view)
        mapView.mapboxMap.loadStyleURI(styleURI)
        
        mapView.didTapAnnotations = { [weak self] in
            let points = Set($0.map(\.id))
            self?.viewModel.handleActionEvent(.tapFeedingPoints(Array(points)))
        }
        
        mapView.cameraAnimationQueue.append {
            self.updateCameraSettings()
        }
    }
    
    func updateCameraEasePadding() {
        let segmentedControl = segmentedControl.superview?
            .convert(segmentedControl.frame, to: mapView.view) ?? .zero
        let userLocationButton = userLocationButton.superview?
            .convert(userLocationButton.frame, to: mapView.view) ?? .zero
        
        let padding: CGFloat = 32
        mapView.cameraEasePadding = UIEdgeInsets(
            top: segmentedControl.maxY + padding,
            left: padding,
            bottom: mapView.view.bounds.maxY - userLocationButton.minY + padding,
            right: padding
        )
    }

    func updateCameraSettings() {
        switch mapView.location.locationProvider.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            userLocationButton.isUserInteractionEnabled = true
        default:
            let tbilisiCenterCoordinates = CLLocationCoordinate2D(
                latitude: 41.719545681547245,
                longitude: 44.78956025041992
            )
            mapView.easeToLocation(tbilisiCenterCoordinates, duration: 0)
            userLocationButton.isUserInteractionEnabled = false
        }
    }

    func easeToClosesFeedingPointOnce(_ items: [FeedingPointViewItem]) {
        DispatchQueue.once {
            let coordinates = items.filter(\.isHungerLevelHigh)

            if let location = mapView.findClosesLocation(coordinates.map { $0.coordinates }) {
                self.mapView.easeToLocation(location, duration: 0)
            }
        }
    }
}

private extension CircleButtonView {
    static func make() -> ButtonView {
        let factory = ButtonViewFactory()
        let myLocationButton = factory.makeMyLocationButton()
        let model = CircleButtonView.Model(
            identifier: UUID().uuidString,
            viewType: CircleButtonView.self,
            icon: Asset.Images.findLocation.image
        )
        myLocationButton.configure(model)
        return myLocationButton
    }
}

private extension FeedingPointViewItem {
    var isHungerLevelHigh: Bool {
        annotationModel.hungerLevel == .high
    }
}
