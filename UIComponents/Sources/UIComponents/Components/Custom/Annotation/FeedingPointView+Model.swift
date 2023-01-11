import UIKit
import Style

extension FeedingPointView {
    public struct Model {
        public let identifier: String
        public let isSelected: Bool
        public let kind: FeedingPointView.Kind

        public init(
            identifier: String,
            isSelected: Bool,
            kind: FeedingPointView.Kind
        ) {
            self.identifier = identifier
            self.isSelected = isSelected
            self.kind = kind
        }
    }

    public enum Kind: Equatable {
        case dog(FeedingPointView.HungerLevel)
        case cat(FeedingPointView.HungerLevel)
        case fav(FeedingPointView.HungerLevel)

        public var isHungerLevelHigh: Bool {
            switch self {
            case .dog(let level):
                return level == .high
            case .cat(let level):
                return level == .high
            case .fav(let level):
                return level == .high
            }
        }

        var image: UIImage {
            switch self {
            case .dog(let level):
                switch level {
                case.high:
                    return Asset.Images.dogHungryHigh.image
                case.medium:
                    return Asset.Images.dogHungryMedium.image
                case .low:
                    return Asset.Images.dogHungryLow.image
                }
            case .cat(let level):
                switch level {
                case.high:
                    return Asset.Images.catHungryHigh.image
                case.medium:
                    return Asset.Images.catHungryMedium.image
                case .low:
                    return Asset.Images.catHungryLow.image
                }
            case .fav(let level):
                switch level {
                case.high:
                    return Asset.Images.favouriteHungryHigh.image
                case.medium:
                    return Asset.Images.favouriteHungryMedium.image
                case .low:
                    return Asset.Images.favouriteHungryLow.image
                }
            }
        }
    }

    public enum HungerLevel: Equatable {
        case high
        case medium
        case low
    }
}
