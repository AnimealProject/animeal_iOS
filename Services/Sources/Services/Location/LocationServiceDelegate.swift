import Foundation
import CoreLocation

// sourcery: AutoMockable
public protocol LocationServiceDelegate: AnyObject {
    func handleLiveLocationStream(result: Result<CLLocation, Error>)
    func handleOneTimeLocation(result: Result<CLLocation, Error>)
}

// MARK: - Optional methods implementation
extension LocationServiceDelegate {
    func handleLiveLocationStream(result: Result<CLLocation, Error>) {}
    func handleOneTimeLocation(result: Result<CLLocation, Error>) {}
}
