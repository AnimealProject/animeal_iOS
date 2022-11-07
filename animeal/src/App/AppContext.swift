import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder &
    AnalyticsServiceHolder &
    AuthenticationServiceHolder &
    DefaultsServiceHolder &
    NetworkServiceHolder &
    UserProfileServiceHolder

struct AppContext: AppContextProtocol {
    let analyticsService: AnalyticsServiceProtocol
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    let authenticationService: AuthenticationServiceProtocol
    let defaultsService: DefaultsServiceProtocol
    let networkService: NetworkServiceProtocol
    let profileService: UserProfileServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let analyticsService = AnalyticsService(logger: Log.shared)
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)
        let authenticationService = AuthenticationService()
        let defaultsService = DefaultsService()
        let networkService = NetworkService()
        let profileService = UserProfileService()

        let context = AppContext(
            analyticsService: analyticsService,
            devLoggerService: devLoggerService,
            locationService: locationService,
            authenticationService: authenticationService,
            defaultsService: defaultsService,
            networkService: networkService,
            profileService: profileService,
            applicationDelegateServices: [
                analyticsService,
                devLoggerService,
                locationService,
                defaultsService
            ]
        )

        return context
    }
}
