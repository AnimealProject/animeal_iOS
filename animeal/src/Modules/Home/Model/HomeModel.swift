import Foundation
import Services

final class HomeModel: HomeModelProtocol {
    private let context: DefaultsServiceHolder
    private var cashedFeedingPoints: [FeedingPoint] = []

    // MARK: - Initialization
    init(context: DefaultsServiceHolder = AppDelegate.shared.context) {
        self.context = context
    }

    // MARK: - Requests
    func fetchFeedingPoints(_ completion: (([FeedingPoint]) -> Void)?) {
        // Fake data used here
        let points = [
            // Akaki Tsereteli Avenue 7, 0119 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.73252135744818, longitude: 44.784740558407265),
                pet: .dog,
                hungerLevel: .low
            ),
            // Spiridon Kedia Street, 0119 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.73234080910943, longitude: 44.78767936105234),
                pet: .dog,
                hungerLevel: .high
            ),
            // Megaline, Razhden Gvetadze St, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.72941679186787, longitude: 44.78358255002624),
                pet: .dog,
                hungerLevel: .mid
            ),
            // Akaki Tsereteli Avenue 2, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.731819746852416, longitude: 44.784159255086905),
                pet: .dog,
                hungerLevel: .low
            ),
            // Megaline, Razhden Gvetadze St, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.72941679186787, longitude: 44.78358255002624),
                pet: .cat,
                hungerLevel: .mid
            ),
            // Akaki Tsereteli Avenue 2, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.731819746852416, longitude: 44.784159255086905),
                pet: .cat,
                hungerLevel: .low
            )
        ]
        cashedFeedingPoints = points
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion?(self.applyFilter(self.cashedFeedingPoints))
        }
    }

    func fetchFilterItems(_ completion: (([FilterItem]) -> Void)?) {
        completion?([
            FilterItem(
                title: L10n.Segment.dogs,
                identifier: .dogs,
                isSelected: selectedFilter == .dogs
            ),
            FilterItem(
                title: L10n.Segment.cats,
                identifier: .cats,
                isSelected: selectedFilter == .cats
            )
        ])
    }

    func proceedFilter(_ identifier: HomeModel.FilterItemIdentifier) {
        context.defaultsService.write(key: Filter.selectedId, value: identifier.rawValue)
    }
}

// MARK: Private API
private extension HomeModel {
    enum Filter: String, LocalStorageKeysProtocol {
        case selectedId = "selectedFilterId"
    }

    var selectedFilter: HomeModel.FilterItemIdentifier {
        let selectedId = context.defaultsService.value(key: Filter.selectedId) ?? 0
        return HomeModel.FilterItemIdentifier(rawValue: selectedId) ?? .dogs
    }

    func applyFilter(_ points: [FeedingPoint]) -> [FeedingPoint] {
        switch selectedFilter {
        case .dogs:
            return points.filter {
                $0.pet == .dog
            }
        case .cats:
            return points.filter {
                $0.pet == .cat
            }
        }
    }
}
