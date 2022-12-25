import Foundation

// sourcery: AutoMockable
protocol FeedingPointMappable {
    func mapFeedingPoint(_ input: animeal.FeedingPoint, feeding: Bool) -> HomeModel.FeedingPoint
}

final class FeedingPointMapper: FeedingPointMappable {
    func mapFeedingPoint(_ input: animeal.FeedingPoint, feeding: Bool) -> HomeModel.FeedingPoint {
        return HomeModel.FeedingPoint(
            identifier: input.id,
            location: HomeModel.Location(
                latitude: input.location.lat,
                longitude: input.location.lon
            ),
            pet: convert(categoryTag: input.category.tag),
            hungerLevel: feeding ? .mid : conver(pointStatus: input.status)
        )
    }

    private func conver(pointStatus: FeedingPointStatus) -> HomeModel.HungerLevel {
        switch pointStatus {
        case .starved:
            return .high
        case .pending:
            return .mid
        case .fed:
            return .low
        }
    }

    private func convert(categoryTag: animeal.CategoryTag) -> HomeModel.Pet {
        switch categoryTag {
        case .cats:
            return HomeModel.Pet.cats
        case .dogs:
            return HomeModel.Pet.dogs
        }
    }
}
