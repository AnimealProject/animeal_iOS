import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps
import Style

class NavigationMapController: NavigationViewControllerDelegate {
    private enum Constants {
        static let cameraDebounceInterval: TimeInterval = 0.5
        static let feedingPointsLayerId = "feeding-points"
        static let clusterCircleLayerId = "mapbox-iOS-cluster-circle-layer-manager-feeding-points"
        static let clusterTextLayerId = "mapbox-iOS-cluster-text-layer-manager-feeding-points"
        static let clusterStarvedIndicatorLayerId = "feeding-points-starved-indicator"
        static let starvedProperty = "starved"
        static let clusterRadius: Double = 50
        static let clusterMaxZoom: Double = 14
        static let clusterZoomDuration: TimeInterval = 0.45
    }

    // MARK: - Private properties
    private let navigationMapView: NavigationMapView
    private var navigationRouteOptions: NavigationRouteOptions?

    private var currentRouteIndex = 0 {
        didSet {
            showCurrentRoute()
        }
    }

    private var currentRoute: Route? {
        return routes?[currentRouteIndex]
    }

    private var routes: [Route]? {
        return routeResponse?.routes
    }

    private var routeResponse: RouteResponse? {
        didSet {
            guard currentRoute != nil else {
                navigationMapView.removeRoutes()
                return
            }
            currentRouteIndex = 0
        }
    }

    // MARK: - Accessible properties
    var didChangeLocation: ((CLLocation, Bool) -> Void)?
    var didTapAnnotations: (([Annotation]) -> Void)?
    var onCameraIdle: ((CoordinateBounds, Double) -> Void)?

    private var lastTapLocation: CGPoint?
    private weak var tapGestureRecognizer: UITapGestureRecognizer?
    private var cameraChangedCancelable: (any Cancelable)?
    private var styleLoadedCancelable: (any Cancelable)?
    private var cameraDebounceTimer: Timer?

    var view: UIView {
        return navigationMapView
    }

    var mapboxMap: MapboxMap {
        return navigationMapView.mapView.mapboxMap
    }

    var location: LocationManager {
        return navigationMapView.mapView.location
    }

    private lazy var annotationManager: (point: PointAnnotationManager, polygon: PolygonAnnotationManager) = {
        let point = navigationMapView.mapView.annotations.makePointAnnotationManager(
            id: Constants.feedingPointsLayerId,
            clusterOptions: Self.makeClusterOptions()
        )
        let polygon = navigationMapView.mapView
            .annotations
            .makePolygonAnnotationManager(layerPosition: .below(point.id))
        return (point, polygon)
    }()

    var cameraAnimationQueue = [() -> Void]()

    var cameraEasePadding: UIEdgeInsets = .zero

    // MARK: - Initialization
    init(frame: CGRect) {
        navigationMapView = NavigationMapView(frame: frame, navigationCameraType: .mobile)
        navigationMapView.autoresizingMask = UIView.AutoresizingMask(
            [.flexibleWidth, .flexibleHeight]
        )
        navigationMapView.userLocationStyle = .puck2D(configuration: .makeDefault(showBearing: true))
        navigationMapView.delegate = self

        let navigationViewportDataSource = NavigationViewportDataSource(
            navigationMapView.mapView,
            viewportDataSourceType: .raw
        )
        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource

        navigationMapView.mapView.mapboxMap.onNext(event: .mapIdle) { [weak self] _ in
            self?.cameraAnimationQueue.forEach { animation in
                animation()
            }
            self?.cameraAnimationQueue.removeAll()
        }

        cameraChangedCancelable = navigationMapView.mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
            guard let self else { return }
            self.cameraDebounceTimer?.invalidate()
            self.cameraDebounceTimer = Timer.scheduledTimer(
                withTimeInterval: Constants.cameraDebounceInterval, repeats: false
            ) { [weak self] _ in
                guard let self else { return }
                let zoom = self.navigationMapView.mapView.mapboxMap.cameraState.zoom
                let bounds = self.navigationMapView.mapView.mapboxMap.coordinateBounds(
                    for: self.navigationMapView.mapView.bounds
                )
                self.onCameraIdle?(bounds, zoom)
            }
        }

        annotationManager.point.delegate = self
        configureClusterAppearance()
        styleLoadedCancelable = navigationMapView.mapView.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
            self?.configureClusterAppearance()
        }
        setupTapGesture()
    }

    deinit {
        cameraDebounceTimer?.invalidate()
        if let tapGestureRecognizer {
            view.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleMapTap(_:)))
        tapGesture.cancelsTouchesInView = false
        navigationMapView.mapView.addGestureRecognizer(tapGesture)
        tapGestureRecognizer = tapGesture
    }

    @objc private func handleMapTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = gesture.location(in: navigationMapView.mapView)
        lastTapLocation = location
        expandCluster(at: location)
    }

    // MARK: - Public API
    func startLocationConsumer() {
        navigationMapView.mapView.location.addLocationConsumer(newConsumer: self)
    }

    func stopLocationConsumer() {
        navigationMapView.mapView.location.removeLocationConsumer(consumer: self)
    }

    func loadStyleURI(_ styleURI: StyleURI) {
        navigationMapView.mapView.mapboxMap.loadStyleURI(styleURI)
    }

    func easeToUserLocation() {
        easeToLocation(navigationMapView.mapView.location.latestLocation?.coordinate, duration: 0)
    }

    private func camera(for coordinates: [CLLocationCoordinate2D]) -> CameraOptions {
        mapboxMap.camera(for: coordinates, padding: cameraEasePadding, bearing: 0, pitch: 0)
    }

    func easeToLocation(
        _ locationCoordinate: CLLocationCoordinate2D?,
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) {
        navigationMapView.mapView.camera.ease(
            to: camera(for: [locationCoordinate].compactMap { $0 }),
            duration: duration,
            curve: curve,
            completion: completion
        )
    }

    func easeToDefaultZoomLocation(
        _ locationCoordinate: CLLocationCoordinate2D?,
        duration: TimeInterval
    ) {
        var cameraOptions = camera(for: [locationCoordinate].compactMap { $0 })
        cameraOptions.zoom = 16.0
        navigationMapView.mapView.camera.ease(
            to: cameraOptions,
            duration: duration,
            curve: .easeOut,
            completion: nil
        )
    }


    func easeToLocations(
        _ locationCoordinates: [CLLocationCoordinate2D],
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) {

        if locationCoordinates.count == 1, let locationCoordinate = locationCoordinates.first {
            easeToLocation(locationCoordinate, duration: duration, curve: curve, completion: completion)
            return
        }

        navigationMapView.mapView.camera.ease(
            to: camera(for: locationCoordinates),
            duration: duration,
            curve: curve,
            completion: completion
        )
    }

    func easeToAnnotations(
        _ annotations: [Annotation],
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) {
        let groupedAnnotations = Dictionary(grouping: annotations, by: \.id).values
        let coordinates = groupedAnnotations.reduce(into: [CLLocationCoordinate2D]()) { result, annotations in
            let coordinates = annotations.reduce(into: [CLLocationCoordinate2D]()) { result, annotation in
                switch annotation.geometry {
                case .point(let point):
                    result.append(point.coordinates)
                case .polygon(let polygon):
                    guard let center = polygon.center else { return }
                    let coordinates = polygon.coordinates.flatMap { $0 }

                    let containsSameCenter = result.contains { $0.distance(to: center) < 5 }
                    guard containsSameCenter else {
                        result.append(contentsOf: coordinates)
                        return
                    }

                    let radius = coordinates.first?.distance(to: center) ?? 0
                    // append only polygons with distance to center or radius greater that 30 meters
                    guard radius > 30 else { return }
                    result.append(contentsOf: coordinates)
                default:
                    assertionFailure("Not supported geometry, \(annotation.geometry)")
                }
            }

            result.append(contentsOf: coordinates)
        }

        easeToLocations(coordinates, duration: duration, curve: curve, completion: completion)
    }

    func findClosesLocation(_ locationCoordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        let currentLocation = navigationMapView.mapView.location.latestLocation?.location

        var closestLocation: CLLocation?
        var smallestDistance: CLLocationDistance?

        let permittedDistinationInMeters: CLLocationDistance = 10000

        locationCoordinates.forEach { locationCoordinate in
            let location = CLLocation(
                latitude: locationCoordinate.latitude,
                longitude: locationCoordinate.longitude
            )

            if let distance = currentLocation?.distance(from: location),
               distance <= permittedDistinationInMeters,
               smallestDistance == nil || distance < smallestDistance ?? 0 {

                closestLocation = location
                smallestDistance = distance
            }
        }
        return closestLocation?.coordinate
    }

    func setAnnotations(_ annotations: [Annotation]) {
        annotationManager.point.annotations = annotations.compactMap { $0 as? PointAnnotation }
        annotationManager.polygon.annotations = annotations.compactMap { $0 as? PolygonAnnotation }
    }

    func getAnnotations(for ids: [String]) -> [Annotation] {
        (annotationManager.point.annotations + annotationManager.polygon.annotations)
            .filter { ids.contains($0.id) }
    }
}

// MARK: - Managing navigationRoute requests
extension NavigationMapController {
    func requestRoute(destination: CLLocationCoordinate2D, completion: ((Result<Void, Error>) -> Void)?) {
        guard let userLocation = navigationMapView.mapView.location.latestLocation else {
            completion?(.success(()))
            return
        }

        let location = CLLocation(
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude
        )

        let userWaypoint = Waypoint(
            location: location,
            heading: userLocation.heading,
            name: .empty
        )

        let destinationWaypoint = Waypoint(coordinate: destination)

        let navigationRouteOptions = NavigationRouteOptions(
            waypoints: [userWaypoint, destinationWaypoint], profileIdentifier: .walking
        )

        Directions.shared.calculate(navigationRouteOptions) { [weak self] _, result in
            switch result {
            case .success(let response):
                guard let self = self else { return }

                self.navigationRouteOptions = navigationRouteOptions
                self.routeResponse = response

                if let routes = self.routes,
                   let currentRoute = self.currentRoute {
                    self.navigationMapView.show(routes)
                    self.navigationMapView.showWaypoints(on: currentRoute)
                }
                completion?(.success(()))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    func cancelRouteRequest() {
        routeResponse = nil
        self.navigationMapView.removeRoutes()
        self.navigationMapView.removeWaypoints()
    }
}

// MARK: - Clustering
private extension NavigationMapController {
    static func makeClusterOptions() -> ClusterOptions {
        let circleRadius = Exp(.step) {
            Exp(.get) { "point_count" }
            18
            10
            22
            25
            28
            50
            34
        }
        return ClusterOptions(
            circleRadius: .expression(circleRadius),
            circleColor: .constant(StyleColor(Asset.Colors.darkTurquoise.color)),
            textColor: .constant(StyleColor(Asset.Colors.light.color)),
            textSize: .constant(13),
            clusterRadius: Constants.clusterRadius,
            clusterMaxZoom: Constants.clusterMaxZoom,
            clusterProperties: [Constants.starvedProperty: Self.starvedClusterProperty()]
        )
    }

    func configureClusterAppearance() {
        let style = mapboxMap.style
        guard style.layerExists(withId: Constants.clusterCircleLayerId),
              style.layerExists(withId: Constants.clusterTextLayerId) else {
            return
        }
        try? style.setLayerProperty(for: Constants.clusterCircleLayerId, property: "circle-stroke-width", value: 2)
        try? style.setLayerProperty(
            for: Constants.clusterCircleLayerId,
            property: "circle-stroke-color",
            value: "#FFFFFF"
        )
        try? style.setLayerProperty(for: Constants.clusterTextLayerId, property: "text-allow-overlap", value: true)
        try? style.setLayerProperty(for: Constants.clusterTextLayerId, property: "text-ignore-placement", value: true)
        try? style.moveLayer(withId: Constants.clusterCircleLayerId, to: .below(Constants.feedingPointsLayerId))
        try? style.moveLayer(withId: Constants.clusterTextLayerId, to: .above(Constants.feedingPointsLayerId))
        installStarvedIndicator()
        try? style.moveLayer(
            withId: Constants.clusterStarvedIndicatorLayerId,
            to: .above(Constants.clusterTextLayerId)
        )
    }

    static func starvedClusterProperty() -> Expression {
        Exp(.max) {
            Exp(.toNumber) {
                Exp(.get) {
                    Constants.starvedProperty
                    Exp(.get) { "userInfo" }
                }
            }
        }
    }

    func installStarvedIndicator() {
        let style = mapboxMap.style
        let layerId = Constants.clusterStarvedIndicatorLayerId
        guard !style.layerExists(withId: layerId) else { return }

        var indicator = CircleLayer(id: layerId)
        indicator.source = Constants.feedingPointsLayerId
        indicator.filter = Exp(.all) {
            Exp(.has) { "point_count" }
            Exp(.gt) {
                Exp(.toNumber) {
                    Exp(.get) { Constants.starvedProperty }
                }
                0
            }
        }
        indicator.circleRadius = .constant(6)
        indicator.circleColor = .constant(StyleColor(Asset.Colors.carminePink.color))
        indicator.circleStrokeWidth = .constant(2)
        indicator.circleStrokeColor = .constant(StyleColor(Asset.Colors.light.color))
        indicator.circleTranslate = .constant([16, -16])
        do {
            try style.addPersistentLayer(indicator, layerPosition: .above(Constants.clusterTextLayerId))
        } catch {
            logError(error.localizedDescription)
        }
    }

    func clusterQueryLayerIds() -> [String] {
        var layerIds = [
            Constants.clusterTextLayerId,
            Constants.clusterCircleLayerId,
            Constants.feedingPointsLayerId
        ]
        if mapboxMap.style.layerExists(withId: Constants.clusterStarvedIndicatorLayerId) {
            layerIds.insert(Constants.clusterStarvedIndicatorLayerId, at: 0)
        }
        return layerIds
    }

    func expandCluster(at point: CGPoint) {
        let options = RenderedQueryOptions(
            layerIds: clusterQueryLayerIds(),
            filter: nil
        )
        mapboxMap.queryRenderedFeatures(with: point, options: options) { [weak self] result in
            guard let self,
                  case .success(let queriedFeatures) = result,
                  let cluster = queriedFeatures.first?.feature,
                  self.isCluster(cluster),
                  case .point(let clusterPoint) = cluster.geometry else {
                return
            }
            self.zoomToCluster(cluster, coordinate: clusterPoint.coordinates)
        }
    }

    func isCluster(_ feature: Feature) -> Bool {
        guard let pointCount = feature.properties?["point_count"] else {
            return false
        }
        if case .number = pointCount {
            return true
        }
        return false
    }

    func zoomToCluster(_ cluster: Feature, coordinate: CLLocationCoordinate2D) {
        mapboxMap.getGeoJsonClusterExpansionZoom(
            forSourceId: Constants.feedingPointsLayerId,
            feature: cluster
        ) { [weak self] result in
            guard let self else { return }
            let currentZoom = self.mapboxMap.cameraState.zoom
            let expansionZoom = (try? result.get()).flatMap { self.zoomLevel(from: $0.value) }
            let targetZoom = expansionZoom.map { max($0 + 0.01, currentZoom + 1) } ?? currentZoom + 1
            let camera = CameraOptions(
                center: coordinate,
                padding: self.cameraEasePadding,
                zoom: targetZoom
            )
            self.navigationMapView.mapView.camera.ease(
                to: camera,
                duration: Constants.clusterZoomDuration,
                curve: .easeOut,
                completion: nil
            )
        }
    }

    func zoomLevel(from value: Any?) -> CGFloat? {
        switch value {
        case let zoom as Double:
            return CGFloat(zoom)
        case let zoom as Int:
            return CGFloat(zoom)
        case let zoom as NSNumber:
            return CGFloat(truncating: zoom)
        default:
            return nil
        }
    }
}

// MARK: - Private API
private extension NavigationMapController {
    func showCurrentRoute() {
        guard let currentRoute = currentRoute, let localRoutes = self.routes else {
            return
        }

        var routes = [currentRoute]
        routes.append(contentsOf: localRoutes.filter {
            $0 != currentRoute
        })
        navigationMapView.showcase(routes)
    }
}

// MARK: - LocationConsumer delegate conformance
extension NavigationMapController: LocationConsumer {
    func locationUpdate(newLocation: MapboxMaps.Location) {
        if routeResponse == nil { return } // If no route no route draw.
        didChangeLocation?(newLocation.location, currentRoute == nil)
    }
}

// MARK: - NavigationMapViewDelegate conformance
extension  NavigationMapController: NavigationMapViewDelegate {
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
    }
}

// MARK: - AnnotationInteractionDelegate conformance
extension NavigationMapController: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard !annotations.isEmpty else {
            lastTapLocation = nil
            return
        }

        let sortedAnnotations: [Annotation]
        if let tapLocation = lastTapLocation, annotations.count > 1 {
            let tapCoordinate = navigationMapView.mapView.mapboxMap.coordinate(for: tapLocation)
            sortedAnnotations = annotations.sorted { annotation1, annotation2 in
                distance(from: tapCoordinate, to: annotation1) < distance(from: tapCoordinate, to: annotation2)
            }
        } else {
            sortedAnnotations = annotations
        }

        lastTapLocation = nil
        didTapAnnotations?(sortedAnnotations)
    }

    private func distance(from coordinate: CLLocationCoordinate2D, to annotation: Annotation) -> CLLocationDistance {
        guard let annotationCoordinate = getCoordinate(from: annotation) else {
            return .infinity
        }
        return coordinate.distance(to: annotationCoordinate)
    }

    private func getCoordinate(from annotation: Annotation) -> CLLocationCoordinate2D? {
        switch annotation.geometry {
        case .point(let point):
            return point.coordinates
        case .polygon(let polygon):
            return polygon.center
        default:
            return nil
        }
    }
}

// MARK: - CLLocationCoordinate2D Extension
private extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
