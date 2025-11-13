//
//  FeedingPointsServiceAdapter.swift
//  animeal
//
//  Created on 02.11.2025.
//

import Foundation
import Combine

import Services

final class FeedingPointsServiceAdapter: FeedingPointsServiceProtocol {
    
    private let mockService: FeedingPointsServiceProtocol
    private let realService: FeedingPointsServiceProtocol
    private let profileService: UserProfileServiceProtocol
    
    private var currentImplementation: FeedingPointsServiceProtocol {
        let validationModel = profileService.getCurrentUserValidationModel()
        let isGuestMode = validationModel.userMode == .guest
        return isGuestMode ? mockService : realService
    }
    
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
        
        logInfo("[FeedingPointsServiceAdapter] Initialized with dynamic service switching")
    }
    
    var storedFeedingPoints: [FullFeedingPoint] {
        currentImplementation.storedFeedingPoints
    }
    
    var storedFavouriteFeedingPoints: [FullFeedingPoint] {
        currentImplementation.storedFavouriteFeedingPoints
    }
    
    var feedingPoints: AnyPublisher<[FullFeedingPoint], Never> {
        currentImplementation.feedingPoints
    }
    
    var changedFeedingPoint: AnyPublisher<FullFeedingPoint, Never> {
        currentImplementation.changedFeedingPoint
    }
    
    func fetchAll() async throws -> [FullFeedingPoint] {
        try await currentImplementation.fetchAll()
    }
    
    func fetch(byIdentifier identifier: String) async throws -> FullFeedingPoint {
        try await currentImplementation.fetch(byIdentifier: identifier)
    }
    
    func fetchFeedingHistory(for feedingPointId: String) async throws -> [FeedingHistory] {
        try await currentImplementation.fetchFeedingHistory(for: feedingPointId)
    }
    
    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        try await currentImplementation.canBookFeedingPoint(for: identifier)
    }
    
    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        try await currentImplementation.fetchAllFavorites()
    }
    
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentImplementation.addToFavorites(byIdentifier: identifier)
    }
    
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentImplementation.deleteFromFavorites(byIdentifier: identifier)
    }
    
    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await currentImplementation.toggleFavorite(byIdentifier: identifier)
    }
}
