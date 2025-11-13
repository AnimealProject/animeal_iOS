//
//  MockFeedingPointsService.swift
//  animeal
//
//  Created on 02.11.2025.
//

import Foundation
import Combine
import Amplify

final class MockFeedingPointsService: FeedingPointsServiceProtocol {

    private let innerFeedingPoints = CurrentValueSubject<[FullFeedingPoint], Never>([])
    private let innerChangedFeedingPoint = PassthroughSubject<FullFeedingPoint, Never>()

    private var mockHistory: [String: [FeedingHistory]] = [:]
    private var mockFeedings: [String: Feeding] = [:]

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

    func fetchAll() async throws -> [FullFeedingPoint] {
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
        try await Task.sleep(nanoseconds: 300_000_000)
        
        if let history = mockHistory[feedingPointId] {
            return history
        }
        
        let history = MockFeedingPointGenerator.generateMockFeedingHistory(
            for: feedingPointId,
            count: Int.random(in: 3...7)
        )
        mockHistory[feedingPointId] = history
        return history
    }
    
    func canBookFeedingPoint(for identifier: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        guard let point = storedFeedingPoints.first(where: { $0.identifier == identifier }) else {
            throw "[MockFeedingPointsService] Cannot check booking status - point not found".asBaseError()
        }
        
        guard point.feedingPoint.status == .starved else {
            return false
        }
        
        return mockFeedings[identifier] == nil
    }
    
    func fetchAllFavorites() async throws -> [FullFeedingPoint] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return storedFavouriteFeedingPoints
    }
    
    func addToFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = storedFeedingPoints.firstIndex(where: { $0.identifier == identifier }) else {
            throw "[MockFeedingPointsService] Cannot add to favorites - point not found".asBaseError()
        }
        
        var points = storedFeedingPoints
        points[index].isFavorite = true
        innerFeedingPoints.send(points)
        innerChangedFeedingPoint.send(points[index])
        
        return FavouriteFeedingPoint(feedingPointId: identifier, isFavorite: true)
    }
    
    func deleteFromFavorites(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let index = storedFeedingPoints.firstIndex(where: { $0.identifier == identifier }) else {
            throw "[MockFeedingPointsService] Cannot remove from favorites - point not found".asBaseError()
        }
        
        var points = storedFeedingPoints
        points[index].isFavorite = false
        innerFeedingPoints.send(points)
        innerChangedFeedingPoint.send(points[index])
        
        return FavouriteFeedingPoint(feedingPointId: identifier, isFavorite: false)
    }
    
    func toggleFavorite(byIdentifier identifier: String) async throws -> FavouriteFeedingPoint {
        guard let point = storedFeedingPoints.first(where: { $0.identifier == identifier }) else {
            throw "[MockFeedingPointsService] Cannot toggle favorite - point not found".asBaseError()
        }
        
        if point.isFavorite {
            return try await deleteFromFavorites(byIdentifier: identifier)
        } else {
            return try await addToFavorites(byIdentifier: identifier)
        }
    }
    
    private func setupMockData() {
        let mockPoints = MockFeedingPointGenerator.generateMockFeedingPoints(count: 15)
        innerFeedingPoints.send(mockPoints)
        
        for point in mockPoints where Bool.random() {
            if let feeding = MockFeedingPointGenerator.generateMockFeeding(for: point.identifier) {
                mockFeedings[point.identifier] = feeding
            }
        }
    }
    
    func updatePointStatus(identifier: String, newStatus: FeedingPointStatus) {
        guard let index = storedFeedingPoints.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        
        var points = storedFeedingPoints
        var point = points[index]
        
        let updatedFeedingPoint = FeedingPoint(
            id: point.feedingPoint.id,
            name: point.feedingPoint.name,
            description: point.feedingPoint.description,
            city: point.feedingPoint.city,
            street: point.feedingPoint.street,
            address: point.feedingPoint.address,
            images: point.feedingPoint.images,
            point: point.feedingPoint.point,
            location: point.feedingPoint.location,
            region: point.feedingPoint.region,
            neighborhood: point.feedingPoint.neighborhood,
            distance: point.feedingPoint.distance,
            status: newStatus,
            i18n: point.feedingPoint.i18n,
            statusUpdatedAt: Temporal.DateTime.now(),
            createdAt: point.feedingPoint.createdAt,
            updatedAt: Temporal.DateTime.now(),
            createdBy: point.feedingPoint.createdBy,
            updatedBy: point.feedingPoint.updatedBy,
            owner: point.feedingPoint.owner,
            pets: point.feedingPoint.pets ?? [],
            category: point.feedingPoint.category,
            users: point.feedingPoint.users ?? [],
            cover: point.feedingPoint.cover,
            feedingPointCategoryId: point.feedingPoint.feedingPointCategoryId
        )
        
        point = FullFeedingPoint(
            feedingPoint: updatedFeedingPoint,
            isFavorite: point.isFavorite,
            imageURL: point.imageURL
        )
        
        points[index] = point
        innerFeedingPoints.send(points)
        innerChangedFeedingPoint.send(point)
    }
}
