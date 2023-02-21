import Foundation
import Services

 typealias AppContextProtocol =
    DevLoggerServiceHolder &
    LocationServiceHolder &
    AnalyticsServiceHolder &
    AuthenticationServiceHolder &
    DefaultsServiceHolder &
    NetworkServiceHolder &
    UserProfileServiceHolder &
    DataStoreServiceHolder &
    FavoritesServiceHolder &
    FeedingPointsServiceHolder

struct AppContext: AppContextProtocol {
    let analyticsService: AnalyticsServiceProtocol
    let devLoggerService: DevLoggerService
    let locationService: LocationServiceProtocol
    let authenticationService: AuthenticationServiceProtocol
    let defaultsService: DefaultsServiceProtocol
    let networkService: NetworkServiceProtocol
    let profileService: UserProfileServiceProtocol
    let dataStoreService: DataStoreServiceProtocol
    let favoritesService: FavoritesServiceProtocol
    let feedingPointsService: FeedingPointsServiceProtocol
    var applicationDelegateServices: [ApplicationDelegateService]

    static func context() -> AppContext {
        let analyticsService = AnalyticsService(logger: Log.shared)
        let devLoggerService = DevLoggerImplementation()
        let locationService = LocationService(locationManager: LocationManager(), logger: Log.shared)
        let authenticationService = AuthenticationService()
        let defaultsService = DefaultsService()
        let networkService = NetworkService()
        let profileService = UserProfileService()
        let dataStoreService = DataStoreService()
        let favoritesService = FavoritesService(
            networkService: networkService,
            profileService: profileService
        )
        let feedingPointsService = FeedingPointsService(
            networkService: networkService,
            dataService: dataStoreService,
            profileService: profileService,
            favoritesService: favoritesService
        )

        let context = AppContext(
            analyticsService: analyticsService,
            devLoggerService: devLoggerService,
            locationService: locationService,
            authenticationService: authenticationService,
            defaultsService: defaultsService,
            networkService: networkService,
            profileService: profileService,
            dataStoreService: dataStoreService,
            favoritesService: favoritesService,
            feedingPointsService: feedingPointsService,
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
