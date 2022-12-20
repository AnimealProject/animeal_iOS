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
    private let networkService: NetworkServiceProtocol

    // MARK: - Initialization
    init(
        sections: [SearchModelSection] = .default,
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService
    ) {
        self.state = .loaded
        self.sections = sections
        self.networkService = networkService
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
        let itemsPerCity = result.reduce([String: [SearchModelItem]]()) { partialResult, point in
            var result = partialResult
            let item = SearchModelItem(
                identifier: point.id,
                name: point.localizedName.removeHtmlTags(),
                description: point.localizedDescription.removeHtmlTags(),
                icon: point.images?.first,
                status: .init(point.status)
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

    func filterFeedingPoints(_ searchString: String?) async -> [SearchModelSection] {
        defer { self.searchString = searchString }
        guard let searchString, !searchString.isEmpty else { return sections }

        let filteredSections = sections.map { section in
            guard !section.title.contains(searchString) else { return section }
            let items = section.items.filter { $0.name.contains(searchString) }
            return SearchModelSection(
                identifier: section.identifier,
                title: section.title,
                items: items,
                expanded: section.expanded
            )
        }

        return filteredSections
    }

    func toogleFeedingPoint(forIdentifier identifier: String) {
        guard let index = sections.firstIndex(
            where: { $0.identifier == identifier }
        ) else { return }

        sections[index].toogle()
    }
}
