import UIKit

// MARK: - View
@MainActor
protocol SearchViewable: AnyObject { }

// MARK: - ViewModel
typealias SearchViewModelProtocol = SearchViewModelLifeCycle
    & SearchViewInteraction
    & SearchViewState

@MainActor
protocol SearchViewModelLifeCycle: AnyObject {
    func setup()
    func load(showLoading: Bool)
}

extension SearchViewModelLifeCycle {
    func load() {
        load(showLoading: true)
    }
}

@MainActor
protocol SearchViewInteraction: AnyObject {
    func handleTextEvent(_ event: SearchViewTextEvent)
    func handleActionEvent(_ event: SearchViewActionEvent)
}

@MainActor
protocol SearchViewState: AnyObject {
    var onContentStateWasPrepared: ((SearchViewContentState) -> Void)? { get set }
    var onFiltersWerePrepared: ((SearchViewFilters) -> Void)? { get set }
    var onSearchInputWasPrepared: ((SearchViewInput) -> Void)? { get set }
}

// MARK: - Model
// sourcery: AutoMockable
protocol SearchModelProtocol: AnyObject {
    func fetchFilteringText() -> String?
    func fetchFeedingPoints(force: Bool) async throws -> [SearchModelSection]
    func fetchFeedingPointsFilters() async -> [SearchModelFilter]

    func filterFeedingPoints(withSearchString searchString: String?) async -> [SearchModelSection]
    func filterFeedingPoints(withFilter identifier: String) async -> [SearchModelSection]

    func toogleFeedingPoint(forIdentifier identifier: String)
    func toogleFavorite(forIdentifier identifier: String) async
}

// MARK: - Coordinator
protocol SearchCoordinatable: Coordinatable, AlertCoordinatable {
    func move(to route: SearchRoute)
}
