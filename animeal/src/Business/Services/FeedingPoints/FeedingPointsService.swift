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

    @discardableResult
    func fetchAll() async throws -> [FullFeedingPoint]
    @discardableResult
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint
    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory]

    
    @discardableResult
    func fetchAllFavorites() async throws -> [FullFeedingPoint]
    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint

    @discardableResult
    func toggle(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint
}

final class FeedingPointsService: FeedingPointsServiceProtocol {
    // MARK: - Subjects
    private let innerFeedingPoints = CurrentValueSubject<[FullFeedingPoint], Never>([])
    private let innerChangedFeedingPoint = PassthroughSubject<FullFeedingPoint, Never>()

    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> {
        innerFeedingPoints.eraseToAnyPublisher()
    }

    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> {
        innerChangedFeedingPoint.eraseToAnyPublisher()
    }

    // MARK: - Accesible properties
    var storedFeedingPoints: [FullFeedingPoint] {
        innerFeedingPoints.value
    }
    
    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        innerFeedingPoints.value.filter { $0.isFavorite }
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
    func fetchAll() async throws -> [FullFeedingPoint] {
        let favoritePoints = try await favoritesService.fetchAll()
        let favoritePointsById = favoritePoints.reduce([String: FavouriteFeedingPoint]()) { partialResult, favourite in
            var result = partialResult
            result[favourite.identifier] = favourite
            return result
        }

        let points = try await networkService
            .query(request: .list(animeal.FeedingPoint.self))
            .asyncMap {
                FullFeedingPoint(
                    feedingPoint: $0,
                    isFavorite: favoritePointsById[$0.id]?.isFavorite == true,
                    imageURL: try? await dataService.getURL(key: $0.cover)
                )
            }

        innerFeedingPoints.send(points)

        return points
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
    
    @discardableResult
    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        let result = try await fetchAll()
        return result.filter { $0.isFavorite }
    }

    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw "[FeedingPointsService] Cannot add to favorites because there is no feeding point for the provided identifier".asBaseError()
        }

        return try await favoritesService.add(point.feedingPoint)
    }

    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await favoritesService.delete(byIdentifier: identifier)
    }

    @discardableResult
    func toggle(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw "[FeedingPointsService] Cannot toggle because there is no feeding point for the provided identifier".asBaseError()
        }

        if point.isFavorite {
            return try await deleteFromFavorites(byIdentifier: identifier)
        } else {
            return try await addToFavorites(byIdentifier: identifier)
        }
    }

    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory] {
        let idPredicate = QueryPredicateOperation(field: "feedingPointId", operator: .equals(feedingPointId))
        let statusPredicate = QueryPredicateOperation(field: "status", operator: .notEqual(FeedingStatus.rejected.rawValue))
        let predicate = QueryPredicateGroup(type: .and, predicates: [idPredicate, statusPredicate])
        async let fetchFeedingHistory = networkService.query(request: .list(FeedingHistory.self, where: predicate))

        let feedingsIdPredicate = QueryPredicateOperation(field: "feedingPointFeedingsId", operator: .equals(feedingPointId))
        async let fetchActiveFeedings = networkService.query(request: .list(Feeding.self, where: feedingsIdPredicate))

        var (activeFeedings, feedingHistory) = try await (fetchActiveFeedings, fetchFeedingHistory)
        if let currentFeeding = activeFeedings.first {
            let current = FeedingHistory(
                userId: currentFeeding.userId,
                createdAt: currentFeeding.createdAt,
                updatedAt: Temporal.DateTime(Date(timeIntervalSince1970: TimeInterval(currentFeeding.expireAt))),
                feedingPointId: currentFeeding.feedingPoint.id,
                status: currentFeeding.status
            )
            feedingHistory.insert(current, at: 0)
        }
        return feedingHistory
    }
}

private extension FeedingPointsService {
    func updateFeedingPoint(byIdentifier identifier: String) {
        Task { [weak self] in
            do {
                try await self?.fetch(byIdentifier: identifier)
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
        networkService.subscribe(request: .onUpdateFeedingPoint()) { [weak self] result in
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

extension List: PropertyContainerPath, PropertyPath, Model where Element: Model {

    public func getModelType() -> Model.Type {
        Element.self
    }

    public func getMetadata() -> PropertyPathMetadata {
        ModelPath<Element>(name: "items", isCollection: true, parent: nil).getMetadata()
    }
}
