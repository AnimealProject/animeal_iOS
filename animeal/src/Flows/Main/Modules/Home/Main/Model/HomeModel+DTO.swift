import Foundation

extension HomeModel {
    struct FeedingPoint {
        let identifier: String
        var isSelected: Bool = false
        let location: Location
        let pet: Pet
        let hungerLevel: HungerLevel
    }

    enum Pet {
        case dogs
        case cats
    }

    enum HungerLevel {
        case high
        case mid
        case low
    }

    struct Location {
        let latitude: Double
        let longitude: Double
    }

    struct FilterItem {
        let title: String
        let identifier: FilterItemIdentifier
        let isSelected: Bool
    }

    enum FilterItemIdentifier: Int {
        case dogs = 0
        case cats = 1
    }
}
