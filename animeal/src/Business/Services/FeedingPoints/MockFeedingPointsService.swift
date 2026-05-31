import Foundation
import Combine
import Amplify

// MARK: - MockFeedingPointsService

final class MockFeedingPointsService: FeedingPointsServiceProtocol {

    private let innerFeedingPoints = CurrentValueSubject<[FullFeedingPoint], Never>([])
    private let innerChangedFeedingPoint = PassthroughSubject<FullFeedingPoint, Never>()

    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> {
        innerFeedingPoints.eraseToAnyPublisher()
    }

    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> {
        innerChangedFeedingPoint.eraseToAnyPublisher()
    }

    var storedFeedingPoints: [FullFeedingPoint] {
        innerFeedingPoints.value
    }

    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        innerFeedingPoints.value.filter { $0.isFavorite }
    }

    init() {
        setupMockData()
    }

    // MARK: - Data Loading

    /// Loads mock data from Bundle JSON file
    private func setupMockData() {
        guard let points = loadFromBundle() else {
            logError("[MockFeedingPointsService] Failed to load guestmock.json - no data available!")
            innerFeedingPoints.send([])
            return
        }

        logInfo("[MockFeedingPointsService] Loaded \(points.count) points from guestmock.json")
        innerFeedingPoints.send(points)
    }

    /// Attempts to load feeding points from Bundle JSON file
    /// - Returns: Array of FullFeedingPoint if successful, nil otherwise
    private func loadFromBundle() -> [FullFeedingPoint]? {
        guard let url = Bundle.main.url(forResource: "guestmock", withExtension: "json") else {
            logWarning("[MockFeedingPointsService] guestmock.json not found in Bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MockFeedingPointsResponse.self, from: data)

            let points = response.feedingPoints.map { dto in
                convertToFullFeedingPoint(dto)
            }

            return points
        } catch {
            logError("[MockFeedingPointsService] Failed to parse guestmock.json: \(error)")
            return nil
        }
    }

    /// Converts MockFeedingPoint to FullFeedingPoint
    private func convertToFullFeedingPoint(_ dto: MockFeedingPoint) -> FullFeedingPoint {
        let status = parseFeedingPointStatus(dto.status)
        let category = createCategory(from: dto.category)

        let location = Location(
            lat: dto.location.lat,
            lon: dto.location.lon
        )

        let point = Point(
            type: "Point",
            coordinates: [dto.location.lon, dto.location.lat]
        )

        let feedingPoint = FeedingPoint(
            id: dto.id,
            name: "",
            description: "",
            city: "",
            street: "",
            address: "",
            images: nil,
            point: point,
            location: location,
            region: "",
            neighborhood: "",
            distance: 0.0,
            status: status,
            i18n: nil,
            statusUpdatedAt: Temporal.DateTime.now(),
            createdAt: Temporal.DateTime.now(),
            updatedAt: Temporal.DateTime.now(),
            createdBy: nil,
            updatedBy: nil,
            owner: nil,
            pets: [],
            category: category,
            users: [],
            cover: nil,
            feedingPointCategoryId: category?.id
        )

        return FullFeedingPoint(
            feedingPoint: feedingPoint,
            isFavorite: false,
            imageURL: nil
        )
    }

    /// Creates Category from string
    private func createCategory(from categoryString: String) -> Category? {
        let tag: CategoryTag
        switch categoryString.lowercased() {
        case "dogs":
            tag = .dogs
        case "cats":
            tag = .cats
        default:
            logWarning("[MockFeedingPointsService] Unknown category '\(categoryString)', defaulting to dogs")
            tag = .dogs
        }

        return Category(
            id: "mock-category-\(categoryString)",
            name: categoryString.capitalized,
            icon: "",
            tag: tag,
            createdAt: Temporal.DateTime.now(),
            updatedAt: Temporal.DateTime.now()
        )
    }

    /// Parses status string to FeedingPointStatus enum
    private func parseFeedingPointStatus(_ statusString: String) -> FeedingPointStatus {
        switch statusString.lowercased() {
        case "starved":
            return .starved
        case "fed":
            return .fed
        case "pending":
            return .pending
        default:
            logWarning("[MockFeedingPointsService] Unknown status '\(statusString)', defaulting to starved")
            return .starved
        }
    }

    // MARK: - FeedingPointsServiceProtocol Implementation

    func resetViewportPoints() {
        innerFeedingPoints.send([])
    }

    func fetchAll(bounds: BoundsInput) async throws -> [FullFeedingPoint] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return storedFeedingPoints
    }

    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        try await Task.sleep(nanoseconds: 300_000_000)

        guard let point = storedFeedingPoints.first(where: { $0.identifier == identifier }) else {
            throw "[MockFeedingPointsService] Feeding point not found for identifier: \(identifier)".asBaseError()
        }

        return point
    }

    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory] {
        // Guest mode doesn't need feeding history - return empty
        try await Task.sleep(nanoseconds: 100_000_000)
        return []
    }

    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        // Guest mode can't book - always return false
        try await Task.sleep(nanoseconds: 100_000_000)
        return false
    }

    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        // Guest mode doesn't support favorites - return empty
        try await Task.sleep(nanoseconds: 100_000_000)
        return []
    }

    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        // Guest mode can't add favorites - throw error or return mock
        try await Task.sleep(nanoseconds: 100_000_000)
        throw "[MockFeedingPointsService] Guest mode does not support favorites".asBaseError()
    }

    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        // Guest mode can't delete favorites - throw error
        try await Task.sleep(nanoseconds: 100_000_000)
        throw "[MockFeedingPointsService] Guest mode does not support favorites".asBaseError()
    }

    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        // Guest mode can't toggle favorites - throw error
        try await Task.sleep(nanoseconds: 100_000_000)
        throw "[MockFeedingPointsService] Guest mode does not support favorites".asBaseError()
    }
}
