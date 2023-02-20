// System
import Foundation

// SDK
import Services
import Common

final class SearchModel: SearchModelProtocol {
    // MARK: - Private properties
    private var sections: [SearchModelSection]
    private var searchString: String?

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

    func fetchFeedingPoints(force: Bool) async throws -> [SearchModelSection] {
        let fetchedSections = try await fetchFeedingPoints(force: force, oldSections: sections)
        let filteredSections = filterFeedingPoints(fetchedSections)
        let foundSections = searchFeedingPoints(
            filteredSections,
            searchString: searchString
        )

        self.sections = fetchedSections

        return foundSections
    }

    func fetchFeedingPointsFilters() async -> [SearchModelFilter] {
        fetchFeedingPointFilters()
    }

    func filterFeedingPoints(withSearchString searchString: String?) async -> [SearchModelSection] {
        self.searchString = searchString

        let filteredSections = filterFeedingPoints(sections)
        let foundSections = searchFeedingPoints(
            filteredSections,
            searchString: searchString
        )

        return foundSections
    }

    func filterFeedingPoints(withFilter identifier: String) async -> [SearchModelSection] {
        searchString = .none

        let filteredSections = filterFeedingPoints(
            sections,
            identifier: identifier
        )
        let foundSections = searchFeedingPoints(
            filteredSections,
            searchString: searchString
        )

        return foundSections
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
}
