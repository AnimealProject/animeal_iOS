import Foundation
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore

final class HomeModel: HomeModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder
    private let context: Context
    private var cashedFeedingPoints: [FeedingPoint] = []

    // MARK: - Initialization
    init(context: Context = AppDelegate.shared.context) {
        self.context = context
    }

    // MARK: - Requests
    func fetchFeedingPoints(_ completion: (([FeedingPoint]) -> Void)?) {
        context.networkService.query(request: .list(animeal.FeedingPoint.self)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let points):
                let feedingPoints = points.map { point in
                    FeedingPoint(
                        identifier: point.id,
                        location: Location(
                            latitude: point.location.lat,
                            longitude: point.location.lon
                        ),
                        pet: point.category.i18n?.first(where: { $0.locale == "en" })?.name == "Dog" ? .dog : .cat,
                        hungerLevel: .high // TODO: Fix hungerLevel
                    )
                }
                self.cashedFeedingPoints = feedingPoints
                DispatchQueue.main.async {
                    completion?(self.applyFilter(self.cashedFeedingPoints))
                }
            case .failure:
                // TODO: Add error handling here
                break
            }
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

    func proceedFeedingPointSelection(_ identifier: String, completion: (([FeedingPoint]) -> Void)?) {
        let modifiedPoints = cashedFeedingPoints.map { point in
            FeedingPoint(
                identifier: point.identifier,
                isSelected: point.identifier == identifier,
                location: point.location,
                pet: point.pet,
                hungerLevel: point.hungerLevel
            )
        }
        cashedFeedingPoints = modifiedPoints
        completion?(self.applyFilter(self.cashedFeedingPoints))
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
