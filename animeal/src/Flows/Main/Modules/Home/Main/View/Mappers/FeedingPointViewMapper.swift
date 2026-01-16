import Foundation
import Style
import UIComponents
import CoreLocation

// sourcery: AutoMockable
protocol FeedingPointViewMappable {
    /// Maps a collection of feeding points to view items, handling overlapping coordinates
    /// - Parameter inputs: Array of feeding point models from the data layer
    /// - Returns: Array of view items with offset coordinates for overlapping points
    func mapFeedingPoints(_ inputs: [HomeModel.FeedingPoint]) -> [FeedingPointViewItem]

    /// Maps a single feeding point to a view item
    /// - Parameter input: Feeding point model from the data layer
    /// - Returns: View item ready for display on the map
    func mapFeedingPoint(_ input: HomeModel.FeedingPoint) -> FeedingPointViewItem
}

final class FeedingPointViewMapper: FeedingPointViewMappable {
    // MARK: - Constants

    private enum Constants {
        /// Offset radius for overlapping markers in degrees (~5.5 meters at equator)
        /// Provides visual separation of markers on map when coordinates match
        static let offsetRadiusInDegrees: Double = 0.00005
    }

    // MARK: - Public API

    func mapFeedingPoints(_ inputs: [HomeModel.FeedingPoint]) -> [FeedingPointViewItem] {
        let coordinateGroups = Dictionary(
            grouping: inputs,
            by: { coordinateKey($0.location.latitude, $0.location.longitude) }
        )
        
        return coordinateGroups
            .sorted(by: { $0.key < $1.key })
            .flatMap { _, group -> [FeedingPointViewItem] in
                if group.count == 1 {
                    return group.compactMap { mapFeedingPoint($0) }
                } else {
                    let sortedGroup = group.sorted { $0.identifier < $1.identifier }
                    return sortedGroup.enumerated().map { index, point in
                        mapFeedingPoint(point, offsetIndex: index, totalCount: sortedGroup.count)
                    }
                }
            }
    }

    func mapFeedingPoint(_ input: HomeModel.FeedingPoint) -> FeedingPointViewItem {
        return mapFeedingPoint(input, offsetIndex: 0, totalCount: 1)
    }
}

// MARK: - Private Mapping

extension FeedingPointViewMapper {
    private func mapFeedingPoint(
        _ input: HomeModel.FeedingPoint,
        offsetIndex: Int,
        totalCount: Int
    ) -> FeedingPointViewItem {
        let originalCoordinates = CLLocationCoordinate2D(
            latitude: input.location.latitude,
            longitude: input.location.longitude
        )

        let displayCoordinates: CLLocationCoordinate2D
        if totalCount > 1 && offsetIndex > 0 {
            displayCoordinates = offsetCoordinate(
                originalCoordinates,
                index: offsetIndex,
                total: totalCount
            )
        } else {
            displayCoordinates = originalCoordinates
        }

        return FeedingPointViewItem(
            coordinates: displayCoordinates,
            originalCoordinates: originalCoordinates,
            radius: input.location.radius,
            isSelected: input.isSelected,
            annotationModel: FeedingPointAnnotationModel(
                identifier: input.identifier,
                kind: convert(input),
                hungerLevel: convert(input.hungerLevel)
            )
        )
    }
}

// MARK: - Coordinate Helpers

extension FeedingPointViewMapper {
    private func coordinateKey(_ latitude: Double, _ longitude: Double) -> String {
        return "\(String(format: "%.5f", latitude)),\(String(format: "%.5f", longitude))"
    }

    private func offsetCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        index: Int,
        total: Int
    ) -> CLLocationCoordinate2D {
        let angle = (Double.pi * 2.0 * Double(index)) / Double(total)

        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + Constants.offsetRadiusInDegrees * cos(angle),
            longitude: coordinate.longitude + Constants.offsetRadiusInDegrees * sin(angle)
        )
    }
}

// MARK: - Type Converters

extension FeedingPointViewMapper {
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
    let originalCoordinates: CLLocationCoordinate2D
    let radius: Measurement<UnitLength>
    let isSelected: Bool
    let annotationModel: FeedingPointAnnotationModel
}
