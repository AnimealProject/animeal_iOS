import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder &
    AnalyticsServiceHolder

struct AppContext: AppContextProtocol {
    let analyticsService: AnalyticsServiceProtocol
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let analyticsService = AnalyticsService(logger: Log.shared)
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)

        let context = AppContext(
            analyticsService: analyticsService,
            devLoggerService: devLoggerService,
            locationService: locationService,
            applicationDelegateServices: [
                analyticsService,
                devLoggerService,
                locationService
            ]
        )

        return context
    }
}
