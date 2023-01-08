// System
import Foundation

// SDK
import Services
import Common

final class SearchModel: SearchModelProtocol {
    // MARK: - Private properties
    private var state: SearchModelState
    private var sections: [SearchModelSection]
    private var searchString: String?

    // MARK: - Dependencies
    private let defaultsService: DefaultsServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let dataService: DataStoreServiceProtocol

    // MARK: - Initialization
    init(
        sections: [SearchModelSection] = .default,
        defaultsService: DefaultsServiceProtocol = AppDelegate.shared.context.defaultsService,
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        dataService: DataStoreServiceProtocol = AppDelegate.shared.context.dataStoreService
    ) {
        self.state = .loaded
        self.sections = sections
        self.defaultsService = defaultsService
        self.networkService = networkService
        self.dataService = dataService
    }

    // MARK: - Requests
    func fetchFilteringText() -> String? { searchString }

    func fetchFeedingPoints(force: Bool) async throws -> [SearchModelSection] {
        guard force else { return await filterFeedingPoints(searchString) }
        let result = try await networkService.query(request: .list(animeal.FeedingPoint.self))
        let sections = result
            .map { $0.localizedCity.removeHtmlTags() }
            .uniqueValues
            .map {
                SearchModelSection(
                    identifier: UUID().uuidString,
                    title: $0,
                    items: [],
                    expanded: false
                )
            }
        let itemsPerCity = await result.asyncReduce([String: [SearchModelItem]]()) { partialResult, point in
            var result = partialResult
            let item = SearchModelItem(
                identifier: point.id,
                name: point.localizedName.removeHtmlTags(),
                description: point.localizedDescription.removeHtmlTags(),
                icon: try? await dataService.getURL(key: point.cover),
                status: .init(point.status),
                category: .init(point.category.tag)
            )
            let city = point.localizedCity.removeHtmlTags()
            var items = result[city] ?? []
            items.append(item)
            result.updateValue(items, forKey: city)

            return result
        }
        let updatedSections = sections.map { section in
            var updatedSection = section
            updatedSection.items = itemsPerCity[section.title] ?? []
            return updatedSection
        }
        self.sections = updatedSections
        return await filterFeedingPoints(searchString)
    }

    func fetchFeedingPointsFilters() async -> [SearchModelFilter] {
        SearchModelItemCategory.allCases.map {
            SearchModelFilter(
                identifier: String($0.rawValue),
                title: $0.text,
                isSelected: $0 == selectedFilter
            )
        }
    }

    func filterFeedingPoints(_ searchString: String?) async -> [SearchModelSection] {
        defer { self.searchString = searchString }
        guard let searchString, !searchString.isEmpty
        else { return applyFilter(selectedFilter, to: sections) }

        let filteredSections = sections.compactMap { section in
            guard !section.title.contains(searchString) else { return section }

            let items = section.items.filter { $0.name.contains(searchString) }
            guard !items.isEmpty else { return nil }

            return SearchModelSection(
                identifier: section.identifier,
                title: section.title,
                items: items,
                expanded: section.expanded
            )
        }

        return applyFilter(selectedFilter, to: filteredSections)
    }

    func filterFeedingPoints(withFilter identifier: String) async -> [SearchModelSection] {
        guard
            let categoryIdentifier = Int(identifier),
            SearchModelItemCategory(rawValue: categoryIdentifier) != nil
        else { return [] }

        searchString = .none
        defaultsService.write(
            key: Filter.selectedId,
            value: categoryIdentifier
        )

        return await filterFeedingPoints(searchString)
    }

    func toogleFeedingPoint(forIdentifier identifier: String) {
        guard let index = sections.firstIndex(
            where: { $0.identifier == identifier }
        ) else { return }

        sections[index].toogle()
    }
}

// MARK: - Filters
private extension SearchModel {
    // TODO: Need to create common file with all keys
    enum Filter: String, LocalStorageKeysProtocol {
        case selectedId = "selectedFilterId"
    }

    var selectedFilter: SearchModelItemCategory {
        let selectedId = defaultsService.value(key: Filter.selectedId) ?? 0
        return SearchModelItemCategory(rawValue: selectedId) ?? .dogs
    }

    func applyFilter(
        _ selectedIdentifier: SearchModelItemCategory,
        to sections: [SearchModelSection]
    ) -> [SearchModelSection] {
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
