import Foundation
import Style
import UIComponents
import CoreLocation

// sourcery: AutoMockable
protocol FeedingPointViewMappable {
    func mapFeedingPoint(_ input: HomeModel.FeedingPoint) -> FeedingPointViewItem
}

final class FeedingPointViewMapper: FeedingPointViewMappable {
    func mapFeedingPoint(_ input: HomeModel.FeedingPoint) -> FeedingPointViewItem {

        return FeedingPointViewItem(
            coordinates: CLLocationCoordinate2D(
                latitude: input.location.latitude,
                longitude: input.location.longitude
            ),
            viewModel: FeedingPointView.Model(
                identifier: input.identifier,
                isSelected: input.isSelected,
                kind: convert(input)
            )
        )
    }

    private func convert(_ input: HomeModel.FeedingPoint) -> FeedingPointView.Kind {
        var hungerLevel = FeedingPointView.HungerLevel.high
        switch input.hungerLevel {
        case .high:
            hungerLevel = .high
        case .mid:
            hungerLevel = .medium
        case .low:
            hungerLevel = .low
        }

        switch input.pet {
        case .cat:
            return .cat(hungerLevel)
        case .dog:
            return .dog(hungerLevel)
        }
    }
}

struct FeedingPointViewItem {
    let coordinates: CLLocationCoordinate2D
    let viewModel: FeedingPointView.Model
}
