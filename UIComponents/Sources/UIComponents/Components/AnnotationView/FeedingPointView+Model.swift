import UIKit
import Style

extension FeedingPointView {
    public struct Model {
        public let identifier: String
        public let kind: FeedingPointView.Kind
        public let action: ((String) -> Void)?

        public init(
            identifier: String,
            kind: FeedingPointView.Kind,
            action: ((String) -> Void)?
        ) {
            self.identifier = identifier
            self.kind = kind
            self.action = action
        }
    }

    public enum Kind {
        case dog(FeedingPointView.HungryLevel)
        case cat(FeedingPointView.HungryLevel)
        case fav(FeedingPointView.HungryLevel)

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

    public enum HungryLevel {
        case high
        case medium
        case low
    }
}
