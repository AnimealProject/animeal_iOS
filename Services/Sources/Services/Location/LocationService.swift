import Foundation
import CoreLocation
import UIKit

public protocol LocationServiceHolder {
    var locationService: LocationServiceProtocol { get }
}

// sourcery: AutoMockable
public protocol LocationServiceProtocol {
    // MARK: - location access status
    var locationStatus: CLAuthorizationStatus { get }
    // MARK: - handle location once
    func requestLocation(for delegate: LocationServiceDelegate)
    // MARK: - handle Real-Time User Location Updates
    func startUpdatingLocation(for delegate: LocationServiceDelegate)
    func stopUpdatingLocation(for delegate: LocationServiceDelegate)
}

public final class LocationService {
    private var liveStreamDelegates = MulticastDelegate<LocationServiceDelegate>()
    private var oneTimeLocationRequestQueue = SynchronizedQueue<LocationServiceDelegate>()
    private let locationManager: LocationManagerProtocol
    private let logger: Logger

    // MARK: - Initialization
    public init(
        locationManager: LocationManagerProtocol,
        logger: Logger
    ) {
        self.locationManager = locationManager
        self.logger = logger
    }
}

// MARK: - LocationService
extension LocationService: LocationServiceProtocol {
    public var locationStatus: CLAuthorizationStatus {
        get {
            return locationManager.authorizationStatus
        }
    }

    public func removeDelegate(_ delegate: LocationServiceDelegate) {
        liveStreamDelegates.removeDelegate(delegate)
    }

    public func requestLocation(for delegate: LocationServiceDelegate) {
        oneTimeLocationRequestQueue.enqueue(delegate)
        locationManager.requestLocation { [weak self] result in
            guard let self = self else { return }
            self.oneTimeLocationRequestQueue.dequeue()?.handleOneTimeLocation(result: result)
        }
    }

    public func startUpdatingLocation(for delegate: LocationServiceDelegate) {
        if !liveStreamDelegates.containsDelegate(delegate) {
            liveStreamDelegates.addDelegate(delegate)
        }
        locationManager.startUpdatingLocation { [weak self] result in
            self?.liveStreamDelegates.invokeDelegates {
                $0.handleLiveLocationStream(result: result)
            }
        }
    }

    public func stopUpdatingLocation(for delegate: LocationServiceDelegate) {
        guard liveStreamDelegates.containsDelegate(delegate) else {
            logger.error("[LocationService] Delegates list does not contains a given delegate")
            return
        }
        liveStreamDelegates.removeDelegate(delegate)
        if liveStreamDelegates.isEmpty {
            locationManager.stopUpdatingLocation()
        }
    }
}

// MARK: - ApplicationService
extension LocationService: ApplicationDelegateService {
    public func registerApplication(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?
    ) -> Bool {
        locationManager.requestAuthorization(mode: .onlyInUse) {[weak self] status in
            self?.logger.info("[LocationService] Current authorization status: \(status)")
        }
        return true
    }
}
