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
    var didChangeLocation: ((CLLocation) -> Void)?

    var view: UIView {
        return navigationMapView
    }

    var mapboxMap: MapboxMap {
        return navigationMapView.mapView.mapboxMap
    }

    var location: LocationManager {
        return navigationMapView.mapView.location
    }

    var viewAnnotations: ViewAnnotationManager {
        return navigationMapView.mapView.viewAnnotations
    }

    var cameraAnimationQueue: [() -> Void] = []

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

    func easeToLocation(
        _ locationCoordinate: CLLocationCoordinate2D?,
        duration: TimeInterval,
        curve: UIView.AnimationCurve = .easeOut,
        completion: AnimationCompletion? = nil
    ) {
        navigationMapView.mapView.camera.ease(
            to: CameraOptions(
                center: locationCoordinate,
                zoom: 16
            ),
            duration: duration,
            curve: curve,
            completion: completion
        )
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
}

// MARK: - Managing navigationRoute requests
extension NavigationMapController {
    func requestRoute(destination: CLLocationCoordinate2D, completion: ((Result<Void, Error>) -> Void)?) {
        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }

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
        didChangeLocation?(newLocation.location)
    }
}

// MARK: - NavigationMapViewDelegate conformance
extension  NavigationMapController: NavigationMapViewDelegate {
    // Delegate method called when the user selects a route
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
    }

    // Delegate method, which is called whenever final destination `PointAnnotation` is added on `MapView`.
    func navigationMapView(
        _ navigationMapView: NavigationMapView,
        didAdd finalDestinationAnnotation: PointAnnotation,
        pointAnnotationManager: PointAnnotationManager
    ) {
        // `PointAnnotationManager` is used to manage `PointAnnotation`s and is also exposed as
        // a property in `NavigationMapView.pointAnnotationManager`. After any modifications to the
        // `PointAnnotation` changes must be applied to `PointAnnotationManager.annotations`
        // array. To remove all annotations for specific `PointAnnotationManager`, set an empty array.
        pointAnnotationManager.annotations = []
    }
}
