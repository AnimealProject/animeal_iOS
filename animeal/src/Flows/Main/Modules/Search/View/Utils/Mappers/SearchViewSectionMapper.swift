// System
import UIKit

// SDK
import Common
import UIComponents
import Style

// sourcery: AutoMockable
protocol SearchViewSectionMappable {
    func mapSection(_ input: SearchModelSection) -> SearchViewSectionWrapper
    func mapSections(_ input: [SearchModelSection]) -> [SearchViewSectionWrapper]
}

final class SearchViewSectionMapper: SearchViewSectionMappable {
    // MARK: - Dependencies
    private let itemMapper: SearchViewItemMapper

    // MARK: - Initialization
    init(itemMapper: SearchViewItemMapper) {
        self.itemMapper = itemMapper
    }

    // MARK: - Mapping
    func mapSection(_ input: SearchModelSection) -> SearchViewSectionWrapper {
        let viewSupplementaryItem = SearchViewSupplementaryExpandableItem(
            title: input.title,
            expanded: input.expanded
        )
        let viewItems = itemMapper.mapItems(input.items)
        let viewSection = SearchViewSection(
            identifier: input.identifier,
            items: viewItems,
            header: viewSupplementaryItem,
            footer: nil,
            expanded: input.expanded
        )
        return SearchViewSectionWrapper(section: viewSection)
    }

    func mapSections(_ input: [SearchModelSection]) -> [SearchViewSectionWrapper] {
        return input.map(mapSection)
    }
}
