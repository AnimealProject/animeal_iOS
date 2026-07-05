//
//  FeedingPointsService.swift
//  animeal
//
//  Created by Диана Тынкован on 15.02.23.
//

// System
import Foundation
import Combine

// SDK
import Services
import Common
import Amplify

struct FullFeedingPoint: Hashable {
    let feedingPoint: FeedingPoint
    var isFavorite: Bool
    var imageURL: URL?

    init(
        feedingPoint: FeedingPoint,
        isFavorite: Bool = true,
        imageURL: URL? = nil
    ) {
        self.feedingPoint = feedingPoint
        self.isFavorite = isFavorite
        self.imageURL = imageURL
    }
}

extension FullFeedingPoint {
    var identifier: String {
        feedingPoint.id
    }
}

protocol FeedingPointsServiceHolder {
    var feedingPointsService: FeedingPointsServiceProtocol { get }
}

protocol FeedingPointsServiceProtocol: AnyObject {
    var storedFeedingPoints: [FullFeedingPoint] { get }
    var storedFavouriteFeedingPoints: [FullFeedingPoint] { get }
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> { get }
    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> { get }

    func resetViewportPoints()

    @discardableResult
    func fetchAll(bounds: BoundsInput) async throws -> [FullFeedingPoint]
    @discardableResult
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint
    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory]
    func canBookFeedingPoint(for identifier: String) async throws -> Bool

    @discardableResult
    func fetchAllFavorites() async throws -> [FullFeedingPoint]
    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
    @discardableResult
    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
}

final class FeedingPointsService: FeedingPointsServiceProtocol {
    // MARK: - Constants
    private enum Constants {
        static let favouritesLimit = 15
    }

    // MARK: - Subjects
    private let innerFeedingPoints = CurrentValueSubject<[FullFeedingPoint], Never>([])
    private let innerFavoritePoints = CurrentValueSubject<[FullFeedingPoint], Never>([])
    private let innerChangedFeedingPoint = PassthroughSubject<FullFeedingPoint, Never>()

    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    private var feedingPointSubscription: AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<UpdateFeedingPoint>>?

    // MARK: - Publishers
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> {
        innerFeedingPoints.combineLatest(innerFavoritePoints)
            .map { Self.merge(viewport: $0, favorites: $1) }
            .eraseToAnyPublisher()
    }

    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> {
        innerChangedFeedingPoint.eraseToAnyPublisher()
    }

    // MARK: - Accesible properties
    var storedFeedingPoints: [FullFeedingPoint] {
        Self.merge(viewport: innerFeedingPoints.value, favorites: innerFavoritePoints.value)
    }

    private static func merge(viewport: [FullFeedingPoint], favorites: [FullFeedingPoint]) -> [FullFeedingPoint] {
        let favoriteIds = Set(favorites.map(\.identifier))
        let viewportIds = Set(viewport.map(\.identifier))
        var result = viewport.map { point -> FullFeedingPoint in
            var updated = point
            updated.isFavorite = favoriteIds.contains(point.identifier)
            return updated
        }
        result += favorites.filter { !viewportIds.contains($0.identifier) }
        return result
    }

    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        innerFavoritePoints.value
    }

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let dataService: DataStoreServiceProtocol
    private let profileService: UserProfileServiceProtocol
    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        dataService: DataStoreServiceProtocol = AppDelegate.shared.context.dataStoreService,
        profileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.networkService = networkService
        self.dataService = dataService
        self.profileService = profileService
        self.favoritesService = favoritesService

        setup()
    }

    @discardableResult
    func fetchAll(bounds: BoundsInput) async throws -> [FullFeedingPoint] {
        let favoriteIds = Set(innerFavoritePoints.value.map(\.identifier))

        // getFeedingPoints returns category as a nested object — no separate fetch needed.
        let rawPoints = try await networkService.query(request: .getFeedingPoints(bounds: bounds))

        let points = await rawPoints.asyncMap {
            FullFeedingPoint(
                feedingPoint: $0,
                isFavorite: favoriteIds.contains($0.id),
                imageURL: try? await dataService.getURL(key: $0.cover)
            )
        }
        let newIds = Set(points.map(\.identifier))
        let kept = innerFeedingPoints.value.filter { !newIds.contains($0.identifier) }
        innerFeedingPoints.send(points + kept)
        return points
    }

    func resetViewportPoints() {
        innerFeedingPoints.send([])
    }

    @discardableResult
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        guard let index = innerFeedingPoints.value.firstIndex(
            where: { $0.identifier == identifier }
        )
        else {
            throw "[FeedingPointsService] There is no feeding point for the provided identifier".asBaseError()
        }

        let oldPoint = innerFeedingPoints.value[index]
        guard let point = try await networkService.query(request: .get(FeedingPoint.self, byId: identifier))
            .map({ FullFeedingPoint(feedingPoint: $0, isFavorite: oldPoint.isFavorite) })
        else {
            throw "[FeedingPointsService] There is no feeding point for the provided identifier".asBaseError()
        }

        replaceFeedingPoint(point, at: index)

        return point
    }

    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw ("[FeedingPointsService] Cannot fetch status because there is no feeding point for the" +
                   " provided identifier").asBaseError()
        }

        guard point.feedingPoint.status == .starved else {
            return false
        }

        let currentUserId = await profileService.getCurrentUser()?.userId

        let idPredicate = QueryPredicateOperation(field: "feedingPointFeedingsId", operator: .equals(identifier))
        let userPredicate = QueryPredicateOperation(field: "userId", operator: .equals(currentUserId))
        let statusPredicate = QueryPredicateOperation(
            field: "status",
            operator: .equals(FeedingStatus.inProgress.rawValue)
        )

        let idPredicates = QueryPredicateGroup(type: .or, predicates: [idPredicate, userPredicate])
        let predicate = QueryPredicateGroup(type: .and, predicates: [idPredicates, statusPredicate])

        let feeding = try await networkService
            .query(request: .list(animeal.Feeding.self, where: predicate)).first

        return (feeding == nil)
    }

    @discardableResult
    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        // TODO: EPMEDU-1635 — replace with a single `getFavoriteFeedingPoints` Lambda query
        // that joins favorites + feeding points on the backend (batchGetItem), removing the
        // need for N parallel requests and the favouritesLimit cap for regular users.
        let allFavorites = try await favoritesService.fetchAll()

        let roles = profileService.getCurrentUserValidationModel().roles
        let isPrivileged = roles.contains(.admin) || roles.contains(.moderator)
        let limitedIDs = isPrivileged
            ? allFavorites.map(\.feedingPointId)
            : Array(allFavorites.prefix(Constants.favouritesLimit).map(\.feedingPointId))

        let networkService = self.networkService
        let dataService = self.dataService

        let points = await withTaskGroup(of: FullFeedingPoint?.self) { group in
            for id in limitedIDs {
                group.addTask {
                    do {
                        guard let point = try await networkService.query(
                            request: .get(FeedingPoint.self, byId: id)
                        ) else { return nil }
                        return FullFeedingPoint(
                            feedingPoint: point,
                            isFavorite: true,
                            imageURL: try? await dataService.getURL(key: point.cover)
                        )
                    } catch {
                        logError("[FeedingPointsService] Failed to fetch favourite \(id): \(error)")
                        return nil
                    }
                }
            }
            var results: [FullFeedingPoint] = []
            for await point in group {
                if let point { results.append(point) }
            }
            return results
        }

        innerFavoritePoints.send(points)
        return points
    }

    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw ("[FeedingPointsService] Cannot add to favorites because there is no feeding point" +
                  " for the provided identifier").asBaseError()
        }

        return try await favoritesService.add(point.feedingPoint)
    }

    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await favoritesService.delete(byIdentifier: identifier)
    }

    @discardableResult
    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw ("[FeedingPointsService] Cannot toggle because there is no feeding point for" +
                   " the provided identifier").asBaseError()
        }

        if point.isFavorite {
            return try await deleteFromFavorites(byIdentifier: identifier)
        } else {
            return try await addToFavorites(byIdentifier: identifier)
        }
    }

    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory] {
        async let fetchFeedingHistory = networkService.query(
            request: .getHistoricalFeedings(feedingPointId: feedingPointId)
        )
        async let fetchActiveFeedings = networkService.query(
            request: .getActiveFeedings(feedingPointId: feedingPointId)
        )

        var (activeFeedings, feedingHistory) = try await (fetchActiveFeedings, fetchFeedingHistory)
        if let currentFeeding = activeFeedings.first {
            let current = FeedingHistory(
                userId: currentFeeding.userId,
                createdAt: currentFeeding.createdAt,
                updatedAt: Temporal.DateTime(Date(timeIntervalSince1970: TimeInterval(currentFeeding.expireAt))),
                feedingPointId: currentFeeding.feedingPointFeedingsId,
                status: currentFeeding.status
            )
            feedingHistory.insert(current, at: 0)
        }
        return feedingHistory
    }

    deinit {
        feedingPointSubscription?.cancel()
    }
}

private extension FeedingPointsService {
    func updateFeedingPoint(byIdentifier identifier: String) {
        Task {
            do {
                try await fetch(byIdentifier: identifier)
            } catch {
                logError("[FeedingPointsService] Feeding point cannot be updated by identifier due to absence.")
            }
        }
    }

    func updateFeedingPoint(_ feedingPoint: FullFeedingPoint) {
        guard let index = innerFeedingPoints.value.firstIndex(
            where: { $0.identifier == feedingPoint.identifier }
        )
        else {
            return logError("[FeedingPointsService] Feeding point cannot be updated due to absence.")
        }

        replaceFeedingPoint(feedingPoint, at: index)
    }

    func updateFeedingPoint(_ favoriteFeedingPoint: FavouriteFeedingPoint) {
        updateFavoritePoints(favoriteFeedingPoint)

        guard let index = innerFeedingPoints.value.firstIndex(
            where: { $0.identifier == favoriteFeedingPoint.identifier }
        )
        else {
            return logError("[FeedingPointsService] Feeding point cannot be updated due to absence.")
        }

        var feedingPoint = innerFeedingPoints.value[index]
        feedingPoint.isFavorite = favoriteFeedingPoint.isFavorite
        replaceFeedingPoint(feedingPoint, at: index)
    }

    func updateFavoritePoints(_ favoriteFeedingPoint: FavouriteFeedingPoint) {
        var favorites = innerFavoritePoints.value
        let index = favorites.firstIndex { $0.identifier == favoriteFeedingPoint.identifier }

        if favoriteFeedingPoint.isFavorite {
            if let index {
                favorites[index].isFavorite = true
            } else if let point = innerFeedingPoints.value.first(
                where: { $0.identifier == favoriteFeedingPoint.identifier }
            ) {
                var favoritePoint = point
                favoritePoint.isFavorite = true
                favorites.append(favoritePoint)
            }
        } else if let index {
            favorites.remove(at: index)
        }

        innerFavoritePoints.send(favorites)
    }

    func replaceFeedingPoint(_ feedingPoint: FullFeedingPoint, at index: Int) {
        updateFeedingPoints { fedingPoints in
            var fedingPoints = fedingPoints
            var feedingPoint = feedingPoint
            feedingPoint.imageURL = fedingPoints[index].imageURL
            fedingPoints.remove(at: index)
            fedingPoints.insert(feedingPoint, at: index)
            return fedingPoints
        }

        innerChangedFeedingPoint.send(feedingPoint)
    }

    func updateFeedingPoints(_ modify: ([FullFeedingPoint]) -> [FullFeedingPoint]) {
        let feedingPoints = innerFeedingPoints.value
        let modifiedFeedingPoints = modify(feedingPoints)
        innerFeedingPoints.send(modifiedFeedingPoints)
    }

    private func setup() {
        feedingPointSubscription = networkService.subscribe(request: .onUpdateFeedingPoint()) { [weak self] result in
            switch result {
            case .success(let updateFeedingPointAction):
                self?.updateFeedingPoint(byIdentifier: updateFeedingPointAction.id)
            case .failure(let error):
                logError(error.localizedDescription)
            }
        }

        favoritesService.changedFavoriteFeedingPoint
            .sink { [weak self] result in
                self?.updateFeedingPoint(result)
            }
            .store(in: &cancellables)
    }
}
