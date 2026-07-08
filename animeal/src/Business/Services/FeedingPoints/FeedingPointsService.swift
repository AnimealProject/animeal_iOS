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

    private struct InnerState {
        var innerFeedingPoints = [FullFeedingPoint]()
        var innerFavoritePoints = [FullFeedingPoint]()
    }

    // MARK: - State
    // Source of truth. All access goes through readState/mutateState — never touch
    // innerState or the lock directly anywhere else in this file.
    private let lock = NSLock()
    private var innerState = InnerState()

    // MARK: - Subjects
    // Broadcast-only mirrors of innerState — written to exclusively from mutateState,
    // never via a direct .send() elsewhere.
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
        readState { Self.merge(viewport: $0.innerFeedingPoints, favorites: $0.innerFavoritePoints) }
    }

    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        readState { $0.innerFavoritePoints }
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
        let favoriteIds = readState { Set($0.innerFavoritePoints.map(\.identifier)) }

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

        mutateState { state in
            let kept = state.innerFeedingPoints.filter { !newIds.contains($0.identifier) }
            state.innerFeedingPoints = points + kept
        }

        return points
    }

    func resetViewportPoints() {
        mutateState { state in
            state.innerFeedingPoints = []
        }
    }

    @discardableResult
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        guard let oldPoint = readState({ $0.innerFeedingPoints.first { $0.identifier == identifier } })
        else {
            throw "[FeedingPointsService] There is no feeding point for the provided identifier".asBaseError()
        }

        guard let point = try await networkService.query(request: .get(FeedingPoint.self, byId: identifier))
            .map({ FullFeedingPoint(feedingPoint: $0, isFavorite: oldPoint.isFavorite) })
        else {
            throw "[FeedingPointsService] There is no feeding point for the provided identifier".asBaseError()
        }

        guard let updated = replaceFeedingPoint(point) else {
            throw "[FeedingPointsService] Feeding point was removed while it was being updated".asBaseError()
        }

        return updated
    }

    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        guard let point = readState({ $0.innerFeedingPoints.first { $0.identifier == identifier } })
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

        // TODO: ANIMEAL-012 follow-up — this still blindly replaces innerFavoritePoints with a
        // snapshot computed at the start of this (long, N-request) fetch. A point-patch that
        // lands on innerState while this fetch is in flight will be overwritten here. Merge by
        // id instead of blind replace — tracked separately, not blocking this fix.
        mutateState { state in
            state.innerFavoritePoints = points
        }

        return points
    }

    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = readState({ $0.innerFeedingPoints.first { $0.identifier == identifier } })
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
        guard let point = readState({ $0.innerFeedingPoints.first { $0.identifier == identifier } })
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
        if replaceFeedingPoint(feedingPoint) == nil {
            logError("[FeedingPointsService] Feeding point cannot be updated due to absence.")
        }
    }

    func updateFeedingPoint(_ favoriteFeedingPoint: FavouriteFeedingPoint) {
        // Both arrays are patched inside a single mutateState call — one lock, one atomic
        // operation — so nothing can observe favorites and viewport disagreeing mid-update.
        let changedPoint: FullFeedingPoint? = mutateState { state in
            let favIndex = state.innerFavoritePoints.firstIndex {
                $0.identifier == favoriteFeedingPoint.identifier
            }

            if favoriteFeedingPoint.isFavorite {
                if let favIndex {
                    state.innerFavoritePoints[favIndex].isFavorite = true
                } else if let point = state.innerFeedingPoints.first(where: {
                    $0.identifier == favoriteFeedingPoint.identifier
                }) {
                    var favoritePoint = point
                    favoritePoint.isFavorite = true
                    state.innerFavoritePoints.append(favoritePoint)
                }
            } else if let favIndex {
                state.innerFavoritePoints.remove(at: favIndex)
            }

            guard let viewportIndex = state.innerFeedingPoints.firstIndex(where: {
                $0.identifier == favoriteFeedingPoint.identifier
            }) else {
                return nil
            }
            state.innerFeedingPoints[viewportIndex].isFavorite = favoriteFeedingPoint.isFavorite
            return state.innerFeedingPoints[viewportIndex]
        }

        if let changedPoint {
            innerChangedFeedingPoint.send(changedPoint)
        }
    }

    @discardableResult
    func replaceFeedingPoint(_ feedingPoint: FullFeedingPoint) -> FullFeedingPoint? {
        let updatedPoint: FullFeedingPoint? = mutateState { state in
            guard let index = state.innerFeedingPoints.firstIndex(where: {
                $0.identifier == feedingPoint.identifier
            }) else {
                return nil
            }
            var feedingPoint = feedingPoint
            feedingPoint.imageURL = state.innerFeedingPoints[index].imageURL
            state.innerFeedingPoints.remove(at: index)
            state.innerFeedingPoints.insert(feedingPoint, at: index)
            return feedingPoint
        }

        if let updatedPoint {
            innerChangedFeedingPoint.send(updatedPoint)
        }

        return updatedPoint
    }

    // Plain mutual exclusion — always exclusive, no reader/writer distinction. Given how
    // rarely this is called (a handful of times per session, not a hot path), the extra
    // throughput of a reader-writer lock isn't worth the added complexity here.
    //
    // Reentrancy note: nothing in this file calls readState/mutateState from inside another
    // readState/mutateState closure — doing so would deadlock (NSLock isn't reentrant). No
    // automatic guard is implemented; keep this invariant in mind when adding new code here.
    private func readState<T>(_ body: (InnerState) -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body(innerState)
    }

    @discardableResult
    private func mutateState<T>(_ body: (inout InnerState) -> T) -> T {
        lock.lock()
        let result = body(&innerState)
        let snapshot = innerState
        lock.unlock()

        // .send() always happens after unlock — never while the lock is held, to avoid a
        // reentrant-call deadlock if a subscriber synchronously calls back into this service
        // from its receiveValue.
        innerFeedingPoints.send(snapshot.innerFeedingPoints)
        innerFavoritePoints.send(snapshot.innerFavoritePoints)

        return result
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
