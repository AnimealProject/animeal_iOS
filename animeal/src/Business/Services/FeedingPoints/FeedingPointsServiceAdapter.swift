import Foundation
import Combine

import Services

final class FeedingPointsServiceAdapter: FeedingPointsServiceProtocol {

    private let mockService: FeedingPointsServiceProtocol
    private let realService: FeedingPointsServiceProtocol
    private let profileService: UserProfileServiceProtocol

    /// Subject that holds the currently active service (mock or real).
    private let currentServiceSubject: CurrentValueSubject<FeedingPointsServiceProtocol, Never>
    /// Cached publisher for the complete list of feeding points.
    private let _feedingPointsPublisher: AnyPublisher<[FullFeedingPoint], Never>
    /// Cached publisher for individual feeding point changes.
    private let _changedFeedingPointPublisher: AnyPublisher<FullFeedingPoint, Never>

    private var cancellables = Set<AnyCancellable>()

    init(
        networkService: NetworkServiceProtocol,
        dataService: DataStoreServiceProtocol,
        profileService: UserProfileServiceProtocol,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.profileService = profileService
        self.mockService = MockFeedingPointsService()
        self.realService = FeedingPointsService(
            networkService: networkService,
            dataService: dataService,
            profileService: profileService,
            favoritesService: favoritesService
        )

        let isGuestMode = profileService.getCurrentUserValidationModel().userMode == .guest
        let initialService = isGuestMode ? mockService : realService
        self.currentServiceSubject = CurrentValueSubject(initialService)

        self._feedingPointsPublisher = currentServiceSubject
            .map { $0.feedingPoints }
            .switchToLatest()
            .eraseToAnyPublisher()

        self._changedFeedingPointPublisher = currentServiceSubject
            .map { $0.changedFeedingPoint }
            .switchToLatest()
            .eraseToAnyPublisher()

        setupUserModeObserver()

        logInfo("[FeedingPointsServiceAdapter] Initialized with \(isGuestMode ? "mock" : "real") service")
    }

    private func setupUserModeObserver() {
        profileService.userModePublisher
            .sink { [weak self] userMode in
                guard let self = self else { return }
                let isGuestMode = userMode == .guest
                let newService = isGuestMode ? self.mockService : self.realService

                // Only switch if service actually changed
                if self.currentServiceSubject.value !== newService {
                    logInfo("[FeedingPointsServiceAdapter] Switching to \(isGuestMode ? "mock" : "real") service")
                    self.currentServiceSubject.send(newService)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Publishers

    /// Publisher that emits the complete list of feeding points.
    ///
    /// This publisher emits the full collection of feeding points whenever they are fetched
    /// or the entire list is updated. It automatically switches between mock and real service
    /// streams based on user mode changes, ensuring subscribers always receive data from
    /// the active service without needing to resubscribe.
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> {
        _feedingPointsPublisher
    }

    /// Publisher that emits individual feeding point updates.
    ///
    /// This publisher emits a single feeding point when it has been specifically modified,
    /// such as status changes, bookings, or favorite toggles. It enables efficient incremental
    /// UI updates without re-rendering the entire collection. Like `feedingPoints`, it automatically
    /// switches between mock and real service streams based on user mode.
    ///
    /// - Returns: A stable publisher instance that remains constant throughout the adapter's lifetime
    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> {
        _changedFeedingPointPublisher
    }

    // MARK: - Synchronous properties delegate to current service

    var storedFeedingPoints: [FullFeedingPoint] {
        currentServiceSubject.value.storedFeedingPoints
    }

    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        currentServiceSubject.value.storedFavouriteFeedingPoints
    }

    // MARK: - Async methods delegate to current service
    func fetchAll(bounds: BoundsInput) async throws -> [FullFeedingPoint] {
        try await currentServiceSubject.value.fetchAll(bounds: bounds)
    }

    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        try await currentServiceSubject.value.fetch(byIdentifier: identifier)
    }

    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory] {
        try await currentServiceSubject.value.fetchFeedingHistory(for: feedingPointId)
    }

    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        try await currentServiceSubject.value.canBookFeedingPoint(for: identifier)
    }

    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        try await currentServiceSubject.value.fetchAllFavorites()
    }

    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentServiceSubject.value.addToFavorites(byIdentifier: identifier)
    }

    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentServiceSubject.value.deleteFromFavorites(byIdentifier: identifier)
    }

    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentServiceSubject.value.toggleFavorite(byIdentifier: identifier)
    }
}
