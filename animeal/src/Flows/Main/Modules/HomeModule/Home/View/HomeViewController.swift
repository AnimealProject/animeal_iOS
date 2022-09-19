import UIKit
import Style
import UIComponents
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
        userLocationButton.onTap = { [weak self] _ in
            self?.easeToUserLocation()
        }
    }

    func setupMapView() {
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
    }

    func easeToUserLocation() {
        mapView.camera.ease(
            to: CameraOptions(
                center: mapView.location.latestLocation?.coordinate,
                zoom: 15
            ),
            duration: 1.3
        )
    }

    func mapInitOptions() -> MapInitOptions {
        let resourceOptions = ResourceOptions(
            accessToken: ResourceOptionsManager.default.resourceOptions.accessToken
        )
        let tbilisiCoordinates = CLLocationCoordinate2D(
            latitude: 41.719545681547245,
            longitude: 44.78956025041992
        )

        return MapInitOptions(
            resourceOptions: resourceOptions,
            cameraOptions: CameraOptions(center: tbilisiCoordinates, zoom: 15),
            styleURI: styleURI
        )
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
