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

typealias FullFeedingPoint = FavouriteFeedingPoint

protocol FeedingPointsServiceHolder {
    var feedingPointsService: FeedingPointsServiceProtocol { get }
}

protocol FeedingPointsServiceProtocol: AnyObject {
    var storedFeedingPoints: [FullFeedingPoint] { get }
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> { get }
    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> { get }

    @discardableResult
    func fetchAll() async throws -> [FullFeedingPoint]
    @discardableResult
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint

    @discardableResult
    func addToFavorites(byIdentifier identifier: String) async throws -> FullFeedingPoint
    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FullFeedingPoint
    
    @discardableResult
    func toggle(byIdentifier identifier: String) async throws -> FullFeedingPoint
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

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let profileService: UserProfileServiceProtocol
    private let favoritesService: FavoritesServiceProtocol

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        profileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.networkService = networkService
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
            .map {
                FullFeedingPoint(
                    feedingPoint: $0,
                    isFavorite: favoritePointsById[$0.id]?.isFavorite == true
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
    func addToFavorites(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        guard let point = innerFeedingPoints.value.first(
            where: { $0.identifier == identifier }
        )
        else {
            throw "[FeedingPointsService] Cannot add to favorites because there is no feeding point for the provided identifier".asBaseError()
        }

        return try await favoritesService.add(point.feedingPoint)
    }

    @discardableResult
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        try await favoritesService.delete(byIdentifier: identifier)
    }
    
    @discardableResult
    func toggle(byIdentifier identifier: String) async throws -> FullFeedingPoint {
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

    func replaceFeedingPoint(_ feedingPoint: FullFeedingPoint, at index: Int) {
        updateFeedingPoints { fedingPoints in
            var fedingPoints = fedingPoints
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
