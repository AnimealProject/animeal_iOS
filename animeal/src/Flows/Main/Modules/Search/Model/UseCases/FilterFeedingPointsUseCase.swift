// System
import Foundation

// SDK
import Services
import Common

protocol FilterFeedingPointsUseCaseLogic {
    func callAsFunction(
        _ sections: [SearchModelSection],
        identifier: String
    ) -> [SearchModelSection]

    func callAsFunction(_ sections: [SearchModelSection]) -> [SearchModelSection]
}

final class FilterFeedingPointsUseCase: FilterFeedingPointsUseCaseLogic {
    private let defaultsService: DefaultsServiceProtocol

    init(
        defaultsService: DefaultsServiceProtocol = AppDelegate.shared.context.defaultsService
    ) {
        self.defaultsService = defaultsService
    }

    func callAsFunction(
        _ sections: [SearchModelSection],
        identifier: String
    ) -> [SearchModelSection] {
        guard
            let categoryIdentifier = Int(identifier),
            SearchModelItemCategory(rawValue: categoryIdentifier) != nil
        else { return [] }

        defaultsService.write(
            key: Filter.selectedId,
            value: categoryIdentifier
        )

        return callAsFunction(sections)
    }

    func callAsFunction(_ sections: [SearchModelSection]) -> [SearchModelSection] {
        switch selectedFilter {
        case .dogs:
            return sections.compactMap { section in
                let items = section.items.filter { $0.category == .dogs }
                guard !items.isEmpty else { return nil }

                return SearchModelSection(
                    identifier: section.identifier,
                    title: section.title,
                    items: items,
                    expanded: section.expanded
                )
            }
        case .cats:
            return sections.compactMap { section in
                let items = section.items.filter { $0.category == .cats }
                guard !items.isEmpty else { return nil }

                return SearchModelSection(
                    identifier: section.identifier,
                    title: section.title,
                    items: items,
                    expanded: section.expanded
                )
            }
        }
    }
}

extension FilterFeedingPointsUseCase: FetchFeedingPointsFiltersUseCaseLogic {
    func callAsFunction() -> [SearchModelFilter] {
        SearchModelItemCategory.allCases.map {
            SearchModelFilter(
                identifier: String($0.rawValue),
                title: $0.text,
                isSelected: $0 == selectedFilter
            )
        }
    }
}

private extension FilterFeedingPointsUseCase {
    // TODO: Need to create common file with all keys
    enum Filter: String, LocalStorageKeysProtocol {
        case selectedId = "selectedFilterId"
    }

    var selectedFilter: SearchModelItemCategory {
        let selectedId = defaultsService.value(key: Filter.selectedId) ?? 0
        return SearchModelItemCategory(rawValue: selectedId) ?? .dogs
    }
}
