import Foundation
import Services
import Amplify
import CoreLocation
import Combine

final class FeedingPointDetailsModel: FeedingPointDetailsModelProtocol, FeedingPointDetailsDataStoreProtocol {
    // MARK: - Private properties
    private let mapper: FeedingPointDetailsModelMapperProtocol

    typealias Context = NetworkServiceHolder
                        & DataStoreServiceHolder
                        & UserProfileServiceHolder
                        & FeedingPointsServiceHolder
                        & ModerationDirectoryServiceHolder
    private let context: Context
    private var cachedFeedingPoint: FullFeedingPoint?
    private var cancellables = Set<AnyCancellable>()
    private var moderatorsTask: Task<Void, Never>?

    // MARK: - DataStore properties
    let feedingPointId: String
    private var canModerate = false
    var feedingPointLocation: CLLocationCoordinate2D {
        guard
            let latitude = cachedFeedingPoint?.feedingPoint.location.lat,
            let longitude = cachedFeedingPoint?.feedingPoint.location.lon
        else {
            return CLLocationCoordinate2D()
        }
        return  CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    // MARK: - Subscription Event
    var onFeedingPointChange: ((FeedingPointDetailsModel.PointContent, Bool) -> Void)?
    var onModeratorsChange: (([FeedingPointDetailsModel.Moderator]) -> Void)?

    // MARK: - Initialization
    init(
        pointId: String,
        mapper: FeedingPointDetailsModelMapperProtocol = FeedingPointDetailsModelMapper(),
        context: Context = AppDelegate.shared.context
    ) {
        self.feedingPointId = pointId
        self.mapper = mapper
        self.context = context
        subscribeForFeedingPointChangeEvents()
        subscribeForFeedingPointModerators()
    }

    // MARK: - Deinitialization
    deinit {
        moderatorsTask?.cancel()
        moderatorsTask = nil
    }

    func fetchFeedingPoint(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        Task { [weak self] in
            guard let self else { return }
            let fullFeedingPoint = context.feedingPointsService.storedFeedingPoints.first { point in
                point.feedingPoint.id == self.feedingPointId
            }

            var canBook = false
            do {
                canBook = try await self.context.feedingPointsService
                    .canBookFeedingPoint(for: self.feedingPointId)
            } catch {
                logError(error.localizedDescription)
            }

            if let feedingPointModel = fullFeedingPoint {
                cachedFeedingPoint = fullFeedingPoint
                completion?(
                    mapper.map(
                        feedingPointModel.feedingPoint,
                        isFavorite: feedingPointModel.isFavorite,
                        isEnabled: canBook
                    )
                )
            }
        }
    }

    func fetchFeedingHistory(_ completion: (([FeedingPointDetailsModel.Feeder]) -> Void)?) {
        Task {
            let history = try await self.fetchFeedingHistory()
            completion?(history)
        }
    }

    func fetchFeedingHistory() async throws -> [FeedingPointDetailsModel.Feeder] {
        guard let fullFeedingPoint = context.feedingPointsService.storedFeedingPoints.first(where: { point in
            point.feedingPoint.id == self.feedingPointId
        }) else {
            return []
        }

        let history = try await context.feedingPointsService.fetchFeedingHistory(for: fullFeedingPoint.identifier)
        guard !history.isEmpty else { return [] }

        let sortedByDateHistory = history.sorted { $0.updatedAt > $1.updatedAt }

        let historyUsers = sortedByDateHistory.map { $0.userId }
        let namesMap = try await context.profileService.fetchUserNames(for: historyUsers)

        let feedingPointDetails = mapper.map(history: sortedByDateHistory, namesMap: namesMap)
        let right = feedingPointDetails.count < 5 ? feedingPointDetails.count : 5
        return Array(feedingPointDetails[..<right])
    }

    private func fetchAssignedModerators() async throws -> [FeedingPointDetailsModel.Moderator] {
        let allModerators = try await context.moderationDirectoryService.fetchModeratorsAndAdmins()
        let feedingPoint = try await context.networkService.query(
            request: .get(FeedingPoint.self, byId: feedingPointId)
        )
        guard let relationUsers = feedingPoint?.users else { return [] }
        try await relationUsers.fetch()

        let assignedUserIds = Set(relationUsers.map(\.userId))
        return allModerators
            .filter { assignedUserIds.contains($0.id) }
            .map { FeedingPointDetailsModel.Moderator(name: $0.name) }
    }

    func mutateFavorite() async throws -> Bool {
        guard let feedingPoint = cachedFeedingPoint else {
            return false
        }
        if feedingPoint.isFavorite {
            try await context.feedingPointsService.deleteFromFavorites(byIdentifier: feedingPointId)
        } else {
            try await context.feedingPointsService.addToFavorites(byIdentifier: feedingPointId)
        }
        return true
    }

    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?) {
        logInfo("[Media] Downloading cover with key: \(key)")
        context.dataStoreService.downloadData(
            key: key,
            options: .init(accessLevel: .guest)
        ) { result in
            switch result {
            case .success(let data):
                logInfo("[Media] Cover downloaded successfully, size: \(data.count) bytes")
                DispatchQueue.main.async {
                    completion?(data)
                }
            case .failure(let error):
                logWarning("[Media] Cover download failed for key '\(key)': \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
        }
    }

    private func updateModerators() {
        guard canModerate else { return }
        moderatorsTask?.cancel()

        moderatorsTask = Task { [weak self] in
            guard let self else { return }
            let moderators = (try? await self.fetchAssignedModerators()) ?? []

            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.onModeratorsChange?(moderators)
            }
        }
    }

    private func subscribeForFeedingPointChangeEvents() {
        context.feedingPointsService.feedingPoints
            .sink { result in
                Task { [weak self] in
                    guard let self else { return }
                    let points = result.uniqueValues
                    let updatedFeeding = points.first {
                        $0.feedingPoint.id == self.feedingPointId
                    }
                    let canBook = try? await self.context.feedingPointsService
                        .canBookFeedingPoint(for: self.feedingPointId)
                    if let feedingPointModel = updatedFeeding,
                       feedingPointModel != self.cachedFeedingPoint {
                        let justFavoriteMutated: Bool
                        if let cached = self.cachedFeedingPoint {
                            justFavoriteMutated = feedingPointModel.onlyFavoriteMutatedOf(cached)
                        } else {
                            justFavoriteMutated = false
                        }
                        let mapped = self.mapper.map(
                            feedingPointModel.feedingPoint,
                            isFavorite: feedingPointModel.isFavorite,
                            isEnabled: canBook ?? false
                        )
                        self.cachedFeedingPoint = feedingPointModel
                        await MainActor.run {
                            self.onFeedingPointChange?(mapped, justFavoriteMutated)
                        }
                        updateModerators()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func subscribeForFeedingPointModerators() {
        context.profileService.userRolePublisher
            .map { roles in
                roles.contains(.admin) || roles.contains(.moderator)
            }
            .removeDuplicates()
            .sink { [weak self] canSeeModerators in
                guard let self else { return }
                canModerate = canSeeModerators
                moderatorsTask?.cancel()
                moderatorsTask = nil

                if !canSeeModerators {
                    Task { @MainActor in
                        self.onModeratorsChange?([])
                    }
                    return
                }
                moderatorsTask = Task { [weak self] in
                    guard let self else { return }
                    let moderators = (try? await self.fetchAssignedModerators()) ?? []

                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        self.onModeratorsChange?(moderators)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension FeedingPointDetailsModel {
    struct PointContent {
        let content: Content
        let action: Action
    }

    struct Content {
        let header: Header
        let description: Description
        let status: Status
        let feeders: [Feeder]
        let moderators: [Moderator]
        let isFavorite: Bool
    }

    struct Feeder {
        let name: String
        let lastFeeded: String
    }

    struct Moderator {
        let name: String
    }

    struct Header {
        let cover: String?
        let title: String
    }

    struct Description {
        let text: String
    }

    struct Action {
        let identifier: String
        let title: String
        let isEnabled: Bool
    }

    enum Status {
        case success(String)
        case attention(String)
        case error(String)
    }
}

private extension FullFeedingPoint {
    func onlyFavoriteMutatedOf(_ point: FullFeedingPoint) -> Bool {
        guard self != point else {
            return false
        }

        if self.identifier != point.identifier ||
            self.imageURL != point.imageURL ||
            self.feedingPoint != point.feedingPoint {
            return false
        }
        return true
    }
}
