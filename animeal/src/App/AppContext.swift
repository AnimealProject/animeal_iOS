import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder &
    AnalyticsServiceHolder &
    AuthenticationServiceHolder &
    DefaultsServiceHolder

struct AppContext: AppContextProtocol {
    let analyticsService: AnalyticsServiceProtocol
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    let authenticationService: AuthenticationServiceProtocol
    let defaultsService: DefaultsServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let analyticsService = AnalyticsService(logger: Log.shared)
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)
        let authenticationService = AuthenticationService()
        let defaultsService = DefaultsService()

        let context = AppContext(
            analyticsService: analyticsService,
            devLoggerService: devLoggerService,
            locationService: locationService,
            authenticationService: authenticationService,
            defaultsService: defaultsService,
            applicationDelegateServices: [
                analyticsService,
                devLoggerService,
                locationService,
                authenticationService,
                defaultsService
            ]
        )

        return context
    }
}
