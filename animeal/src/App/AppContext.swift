import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder &
    AnalyticsServiceHolder &
    AuthenticationServiceHolder

struct AppContext: AppContextProtocol {
    let analyticsService: AnalyticsServiceProtocol
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    let authenticationService: AuthenticationServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let analyticsService = AnalyticsService(logger: Log.shared)
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)
        let authenticationService = AuthenticationService()

        let context = AppContext(
            analyticsService: analyticsService,
            devLoggerService: devLoggerService,
            locationService: locationService,
            authenticationService: authenticationService,
            applicationDelegateServices: [
                analyticsService,
                devLoggerService,
                locationService,
                authenticationService
            ]
        )

        return context
    }
}
