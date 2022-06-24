import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder

struct AppContext: AppContextProtocol {
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)

        let context = AppContext(
            devLoggerService: devLoggerService,
            locationService: locationService,
            applicationDelegateServices: [
                devLoggerService,
                locationService
            ]
        )

        return context
    }
}
