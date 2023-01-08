// System
import UIKit

// SDK
import Common
import UIComponents
import Style

// sourcery: AutoMockable
protocol SearchViewItemMappable {
    func mapItem(_ input: SearchModelItem) -> SearchViewItem
    func mapItems(_ input: [SearchModelItem]) -> [SearchViewItem]
}

final class SearchViewItemMapper: SearchViewItemMappable {
    func mapItem(_ input: SearchModelItem) -> SearchViewItem {
        let viewItem = SearchPointViewItem(
            identifier: input.identifier,
            model: FeedingPointDetailsView.Model(
                placeInfoViewModel: PlaceInfoView.Model(
                    icon: .url(input.icon),
                    title: input.name,
                    status: StatusView.Model(status: mapStatus(input.status))
                ),
                isHighlighted: false
            )
        )
        return viewItem
    }

    func mapItems(_ input: [SearchModelItem]) -> [SearchViewItem] {
        return input.map(mapItem)
    }

    private func mapStatus(_ input: SearchModelItemStatus) -> StatusView.Status {
        switch input {
        case .fed:
            return .success("Newly feed")
        case .pending:
            return .attention("12 hours since not fed")
        case .starved:
            return .error("There is no food")
        }
    }
}
