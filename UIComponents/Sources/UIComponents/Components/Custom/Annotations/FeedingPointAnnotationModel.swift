import UIKit
import Style

public struct FeedingPointAnnotationModel {
    public enum Kind: Equatable {
        case dog, cat
        case fav
    }

    public enum HungerLevel: Equatable {
        case high
        case medium
        case low
    }

    public let identifier: String
    public let kind: Kind
    public let hungerLevel: HungerLevel

    public init(
        identifier: String,
        kind: Kind,
        hungerLevel: HungerLevel
    ) {
        self.identifier = identifier
        self.kind = kind
        self.hungerLevel = hungerLevel
    }
}
