import Foundation
import CoreLocation

public typealias AuthorizationStatus = ((CLAuthorizationStatus) -> Void)
public typealias LocationResponce = ((Result<CLLocation, Error>) -> Void)

public protocol LocationManagerProtocol {
    // MARK: - Authorization
    /// The status of the authorization manager.
    var authorizationStatus: CLAuthorizationStatus { get }
    /// The precise of the authorization manager.
    var authorizationPrecise: CLAccuracyAuthorization { get }

    /// Requests the user’s permission to use location services
    ///
    /// - Parameters:
    ///   - mode: reqiured authorization mode
    ///   - completion: A closure to handle authorization status
    func requestAuthorization(mode: AuthorizationMode, completion: @escaping AuthorizationStatus)

    // MARK: - Get A User’s Location Once
    /// Requests the one-time delivery of the user’s current location.
    ///
    /// This method returns immediately. Calling it causes the location manager to obtain a location
    /// Use this method when you want the user’s current location but do not need to leave location services running.
    ///
    /// - Parameters:
    ///   - completion: A closure to execute on location update.
    ///
    func requestLocation(completion: @escaping LocationResponce)

    // MARK: - Get Real-Time User Location Updates
    /// Starts the generation of updates that report the user’s current location.
    ///
    /// - Parameters:
    ///   - completion: A closure to execute on location update.
    func startUpdatingLocation(completion: @escaping LocationResponce)

    ///  Stops the generation of location updates.
    ///
    ///  Call this method whenever your code no longer needs to receive location-related events.
    ///  You can always restart the generation of location updates by calling the **startUpdatingLocation** method again.
    func stopUpdatingLocation()
}

public final class LocationManager: NSObject {
    // MARK: - Private Properties
    private var locationManager: CLLocationManager
    private var didUpdateLocation: LocationResponce?
    private var authorizationCallbacks: [AuthorizationStatus] = []

    // MARK: - Public Properties
    public var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }

    public var authorizationPrecise: CLAccuracyAuthorization {
        return locationManager.accuracyAuthorization
    }

    // MARK: - Initialization
    override public init() {
        self.locationManager = CLLocationManager()
        super.init()

        self.locationManager.delegate = self
    }
}

// MARK: LocationManager
extension LocationManager: LocationManagerProtocol {
    public func requestAuthorization(
        mode: AuthorizationMode,
        completion callback: @escaping AuthorizationStatus
    ) {
        guard authorizationStatus.isAuthorized == false else {
            callback(authorizationStatus)
            return
        }

        authorizationCallbacks.append(callback)

        switch mode {
        case .always:
            locationManager.requestAlwaysAuthorization()
        case .onlyInUse:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    public func requestLocation(completion: @escaping LocationResponce) {
        didUpdateLocation = completion
        locationManager.startUpdatingLocation()
    }

    public func startUpdatingLocation(completion: @escaping LocationResponce) {
        didUpdateLocation = completion
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        didChangeAuthorizationStatus(manager.authorizationStatus)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didUpdateLocation?(.failure(error))
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            didUpdateLocation?(.success(location))
        }
    }
}

// MARK: - Private Functions
private extension LocationManager {
    func didChangeAuthorizationStatus(_ newStatus: CLAuthorizationStatus) {
        guard newStatus != .notDetermined else {
            return
        }
        let callbacks = authorizationCallbacks
        callbacks.forEach {
            $0(authorizationStatus)
        }
        authorizationCallbacks.removeAll()
    }
}

// MARK: - AuthorizationMode
/// Authorization request mod.
/// - `always`: Authorization mode allows to use location services regardless of whether the app is in use.
/// - `onlyInUse`: Authorization mode allows to use location services while the app is in use.
public enum AuthorizationMode: String {
    case always
    case onlyInUse
}

// MARK: - CLAuthorizationStatus
extension CLAuthorizationStatus: CustomStringConvertible {
    internal var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "always"
        case .authorizedWhenInUse:
            return "whenInUse"
        @unknown default:
            return "unknown"
        }
    }
}
