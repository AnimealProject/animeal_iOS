import UIKit
import Style
import UIComponents
import Common
@_spi(Experimental) import MapboxMaps

class HomeViewController: UIViewController {
    // MARK: - Private properties
    private var mapView: NavigationMapController!
    private let segmentedControl = SegmentedControl()
    private lazy var feedControl: FeedingControlView = {
        let feedControl = FeedingControlView()
        feedControl.onCloseHandler = { [weak self] in
            guard let self = self else { return }
            self.feedControl.stopTimer()
            self.mapView.cancelRouteRequest()
            self.hideFeedControl(true)
        }
        feedControl.onTimerFinishHandler = feedControl.onCloseHandler
        return feedControl
    }()
    private let userLocationButton = CircleButtonView.make()
    private var lacationButtonBottomAnchor: NSLayoutConstraint?
    private var styleURI: StyleURI {
        return UITraitCollection.current.userInterfaceStyle == .dark
        ? StyleURI.dark : StyleURI.streets
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
    override func loadView() {
        super.loadView()
        setupMapView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        viewModel.load()
    }
}

extension HomeViewController: HomeViewModelOutput {
    func applyFeedingPoints(_ feedingPoints: [FeedingPointViewItem]) {
        mapView.viewAnnotations.removeAll()
        feedingPoints.forEach { point in
            let options = ViewAnnotationOptions(
                geometry: MapboxMaps.Point(point.coordinates),
                width: 60,
                height: 60,
                allowOverlap: false,
                anchor: .center
            )
            let feedingPointView = FeedingPointView()
            feedingPointView.configure(point.viewModel)
            feedingPointView.tapAction = { [weak self] pointId in
                self?.viewModel.handleActionEvent(.tapFeedingPoint(pointId))
            }
            try? mapView.viewAnnotations.add(feedingPointView, options: options)
        }

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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let mapView = mapView else { return }
        mapView.mapboxMap.loadStyleURI(styleURI)
    }
}

// MARK: - Private API
private extension HomeViewController {
    func setup() {
        let controlsContainer = UIStackView()
        controlsContainer.axis = .vertical
        controlsContainer.alignment = .center

        view.addSubview(controlsContainer.prepareForAutoLayout())
        controlsContainer.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        controlsContainer.centerXAnchor ~= view.centerXAnchor
        controlsContainer.distribution = .fillProportionally

        controlsContainer.addArrangedSubview(segmentedControl)
        segmentedControl.widthAnchor ~= 226
        controlsContainer.addArrangedSubview(feedControl)
        feedControl.widthAnchor ~= 374
        hideFeedControl(true)

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

        viewModel.onSegmentsHaveBeenPrepared = { [weak self] model in
            self?.applyFilter(model)
        }

        viewModel.onRouteRequestHaveBeenPrepared = { [weak self] coordinates in
            self?.handleRouteRequest(coordinates: coordinates)
        }
    }

    func handleRouteRequest(coordinates: CLLocationCoordinate2D) {
        mapView.requestRoute(destination: coordinates)
        feedControl.startTimer()
        hideFeedControl(false)
        mapView.startLocationConsumer()

        handleLocationChange(
            coordinates,
            location: mapView.location.latestLocation?.location
        )
        mapView.didChangeLocation = { [weak self] location in
            self?.handleLocationChange(
                coordinates,
                location: location
            )
        }
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

    func hideFeedControl(_ state: Bool) {
        segmentedControl.isHidden = !state
        feedControl.isHidden = state
    }
}

// MARK: - MapBox helpers
private extension HomeViewController {
    func setupMapView() {
        mapView = NavigationMapController(frame: view.bounds)
        view.addSubview(mapView.view)
        mapView.mapboxMap.loadStyleURI(styleURI)

        mapView.cameraAnimationQueue.append {
            self.updateCameraSettings()
        }

        mapView.mapboxMap.onNext(event: .mapIdle) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self?.mapView.cameraAnimationQueue.forEach { animation in
                    animation()
                }
                self?.mapView.cameraAnimationQueue.removeAll()
            }
        }
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
            let coordinates = items.filter { viewItem in
                viewItem.viewModel.kind == FeedingPointView.Kind.dog(.high)
                || viewItem.viewModel.kind == FeedingPointView.Kind.cat(.high)
            }

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
