import Foundation

extension HomeModel {
    struct FeedingPoint {
        let identifier: String
        var isSelected: Bool = false
        let location: Location
        let pet: Pet
        let hungerLevel: HungerLevel
        let isFavorite: Bool
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

    struct FeedingAction {
        let title: String
        let actions: [Action]

        struct Action {
            let title: String
            let style: Style
        }

        enum Style {
            case accent
            case inverted
        }
    }

    enum FeedingActionRequest {
        case cancelFeeding
        case autoCancelFeeding
    }
}
