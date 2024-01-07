import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps

class NavigationMapController: NavigationViewControllerDelegate {
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
        let point = navigationMapView.mapView.annotations.makePointAnnotationManager()
        let polygon = navigationMapView.mapView.annotations.makePolygonAnnotationManager(layerPosition: .below(point.id))
        return (point, polygon)
    }()

    var cameraAnimationQueue: [() -> Void] = []

    var cameraEasePadding: UIEdgeInsets = .zero

    // MARK: - Initialization
    init(frame: CGRect) {
        navigationMapView = NavigationMapView(frame: frame, navigationCameraType: .mobile)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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

        annotationManager.point.delegate = self
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

            if
               let distance = currentLocation?.distance(from: location),
               distance <= permittedDistinationInMeters,
               smallestDistance == nil || distance < smallestDistance ?? 0
            {
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
        didTapAnnotations?(annotations)
    }
}
