import Foundation

// sourcery: AutoMockable
protocol FeedingPointMappable {
    func mapFeedingPoint(_ input: animeal.FeedingPoint) -> HomeModel.FeedingPoint
}

final class FeedingPointMapper: FeedingPointMappable {
    func mapFeedingPoint(_ input: animeal.FeedingPoint) -> HomeModel.FeedingPoint {
        return HomeModel.FeedingPoint(
            identifier: input.id,
            location: HomeModel.Location(
                latitude: input.location.lat,
                longitude: input.location.lon
            ),
            pet: convert(categoryTag: input.category.tag),
            hungerLevel: .high // TODO: Add hungerLevel
        )
    }

    func convert(categoryTag: animeal.CategoryTag) -> HomeModel.Pet {
        switch categoryTag {
        case .cats:
            return HomeModel.Pet.cats
        case .dogs:
            return HomeModel.Pet.dogs
        }
    }
}
