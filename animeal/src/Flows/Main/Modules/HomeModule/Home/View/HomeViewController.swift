import UIKit
import Style
import UIComponents
import Common
@_spi(Experimental) import MapboxMaps

class HomeViewController: UIViewController {
    // MARK: - Private properties
    private var mapView: MapView!
    private let segmentedControl = SegmentedControl()
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
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
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

        DispatchQueue.main.async {
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
        setupMapView()

        view.addSubview(segmentedControl.prepareForAutoLayout())
        segmentedControl.topAnchor ~= view.safeAreaLayoutGuide.topAnchor + 66
        segmentedControl.centerXAnchor ~= view.centerXAnchor
        segmentedControl.widthAnchor ~= 226

        view.addSubview(userLocationButton.prepareForAutoLayout())
        userLocationButton.trailingAnchor ~= view.trailingAnchor - 30
        lacationButtonBottomAnchor = userLocationButton.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 38
        userLocationButton.isUserInteractionEnabled = false
        userLocationButton.onTap = { [weak self] _ in
            self?.easeToUserLocation()
        }
    }
}

// MARK: - MapBox helpers
private extension HomeViewController {
    func setupMapView() {
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            self?.updateMapBoxCameraSettings()
        }
    }

    func mapInitOptions() -> MapInitOptions {
        let resourceOptions = ResourceOptions(
            accessToken: ResourceOptionsManager.default.resourceOptions.accessToken
        )

        return MapInitOptions(
            resourceOptions: resourceOptions,
            styleURI: styleURI
        )
    }

    func updateMapBoxCameraSettings() {
        switch mapView.location.locationProvider.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            easeToUserLocation()
            userLocationButton.isUserInteractionEnabled = true
        default:
            // Without a location permissions we ease the camera to center of Tbilisi
            let tbilisiCenterCoordinates = CLLocationCoordinate2D(
                latitude: 41.719545681547245,
                longitude: 44.78956025041992
            )
            easeToLocation(tbilisiCenterCoordinates, duration: 0)
            userLocationButton.isUserInteractionEnabled = false
        }
    }

    func easeToUserLocation() {
        easeToLocation(mapView.location.latestLocation?.coordinate, duration: 0)
    }

    func easeToLocation(
        _ locationCoordinate: CLLocationCoordinate2D?,
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) {
        mapView.camera.ease(
            to: CameraOptions(
                center: locationCoordinate,
                zoom: 15
            ),
            duration: duration,
            curve: curve,
            completion: completion
        )
    }

    func easeToClosesFeedingPointOnce(_ items: [FeedingPointViewItem]) {
        DispatchQueue.once {
                let coordinates = items.filter { viewItem in
                    viewItem.viewModel.kind == FeedingPointView.Kind.dog(.high)
                    || viewItem.viewModel.kind == FeedingPointView.Kind.cat(.high)
                }
                self.easeToLocation(
                    self.findClosesLocation(coordinates.map { $0.coordinates }),
                    duration: 0
                )
        }
    }

    func findClosesLocation(_ locationCoordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        let currentLocation = mapView.location.latestLocation?.location

        var closestLocation: CLLocation?
        var smallestDistance: CLLocationDistance?

        locationCoordinates.forEach { locationCoordinate in
            let location = CLLocation(
                latitude: locationCoordinate.latitude,
                longitude: locationCoordinate.longitude
            )
            // TODO: Sort by distance < 10km
            if let distance = currentLocation?.distance(from: location),
               smallestDistance == nil || distance < smallestDistance ?? 0 {
                closestLocation = location
                smallestDistance = distance
            }
        }
        return closestLocation?.coordinate
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
