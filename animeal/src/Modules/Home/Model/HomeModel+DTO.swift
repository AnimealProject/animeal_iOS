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
        case dog
        case cat
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
}
