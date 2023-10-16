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
            radius: input.location.radius,
            isSelected: input.isSelected,
            annotationModel: FeedingPointAnnotationModel(
                identifier: input.identifier,
                kind: convert(input),
                hungerLevel: convert(input.hungerLevel)
            )
        )
    }

    private func convert(_ input: HomeModel.FeedingPoint) -> FeedingPointAnnotationModel.Kind {
        if input.isFavorite {
            return .fav
        }

        switch input.pet {
        case .cats: return .cat
        case .dogs: return .dog
        }
    }

    private func convert(_ input: HomeModel.HungerLevel) -> FeedingPointAnnotationModel.HungerLevel {
        switch input {
        case .high: return .high
        case .mid: return .medium
        case .low: return .low
        }
    }
}

struct FeedingPointViewItem {
    let coordinates: CLLocationCoordinate2D
    let radius: Measurement<UnitLength>
    let isSelected: Bool
    let annotationModel: FeedingPointAnnotationModel
}
