// System
import Foundation

// SDK
import Services
import Common

enum SearchTag: CaseIterable {
    case all
    case newlyFed
    case noFood
}

final class SearchModel: SearchModelProtocol {
    // MARK: - Private properties
    private var sections: [SearchModelSection]
    private var searchString: String?
    private var selectedTag: SearchTag = .all

    // MARK: - Dependencies
    private let fetchFeedingPoints: FetchFeedingPointsUseCaseLogic
    private let searchFeedingPoints: SearchFeedingPointsUseCaseLogic
    private let filterFeedingPoints: FilterFeedingPointsUseCaseLogic
    private let toggleFavoriteFeedingPoint: ToggleFavoriteFeedingPointUseCaseLogic

    private let fetchFeedingPointFilters: FetchFeedingPointsFiltersUseCaseLogic

    // MARK: - Initialization
    init(
        sections: [SearchModelSection] = .default,
        fetchFeedingPoints: FetchFeedingPointsUseCaseLogic = FetchFeedingPointsUseCase(),
        searchFeedingPoints: SearchFeedingPointsUseCaseLogic = SearchFeedingPointsUseCase(),
        filterFeedingPoints: FilterFeedingPointsUseCaseLogic = FilterFeedingPointsUseCase(),
        toggleFavoriteFeedingPoint: ToggleFavoriteFeedingPointUseCaseLogic = ToggleFavoriteFeedingPointUseCase(),
        fetchFeedingPointFilters: FetchFeedingPointsFiltersUseCaseLogic = FilterFeedingPointsUseCase()
    ) {
        self.sections = sections
        self.fetchFeedingPoints = fetchFeedingPoints
        self.searchFeedingPoints = searchFeedingPoints
        self.filterFeedingPoints = filterFeedingPoints
        self.toggleFavoriteFeedingPoint = toggleFavoriteFeedingPoint
        self.fetchFeedingPointFilters = fetchFeedingPointFilters
    }

    // MARK: - Requests
    func fetchFilteringText() -> String? { searchString }

    func fetchFeedingPoints() async throws -> [SearchModelSection] {
        let fetchedSections = try await fetchFeedingPoints(oldSections: sections)
        self.sections = fetchedSections
        return applyActiveFilters(to: fetchedSections)
    }

    func fetchFeedingPointsFilters() async -> [SearchModelFilter] {
        fetchFeedingPointFilters()
    }

    func filterFeedingPoints(withSearchString searchString: String?) async -> [SearchModelSection] {
        self.searchString = searchString
        return applyActiveFilters(to: sections)
    }

    func filterFeedingPoints(withFilter identifier: String) async -> [SearchModelSection] {
        searchString = .none
        let filteredSections = filterFeedingPoints(sections, identifier: identifier)
        return applySearchAndTag(to: filteredSections)
    }

    func filterFeedingPoints(withTag tag: SearchTag) async -> [SearchModelSection] {
        selectedTag = tag
        return applyActiveFilters(to: sections)
    }

    func toogleFeedingPoint(forIdentifier identifier: String) {
        guard let index = sections.firstIndex(
            where: { $0.identifier == identifier }
        ) else { return }

        sections[index].toogle()
    }

    func toogleFavorite(forIdentifier identifier: String) async {
        await toggleFavoriteFeedingPoint(byIdentifier: identifier)
    }

    private func applyActiveFilters(to sections: [SearchModelSection]) -> [SearchModelSection] {
        applySearchAndTag(to: filterFeedingPoints(sections))
    }

    private func applySearchAndTag(to sections: [SearchModelSection]) -> [SearchModelSection] {
        searchFeedingPoints(filterBySelectedTag(sections), searchString: searchString)
    }

    private func filterBySelectedTag(_ sections: [SearchModelSection]) -> [SearchModelSection] {
        let matchesStatus: (SearchModelItemStatus) -> Bool
        switch selectedTag {
        case .all:
            return sections
        case .newlyFed:
            matchesStatus = { $0 == .fed }
        case .noFood:
            matchesStatus = { $0 == .starved }
        }

        return sections.compactMap { section in
            let items = section.items.filter { matchesStatus($0.status) }
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
