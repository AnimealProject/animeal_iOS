import UIKit

// MARK: - View
@MainActor
protocol SearchViewable: ErrorDisplayable { }

// MARK: - ViewModel
typealias SearchViewModelProtocol = SearchViewModelLifeCycle
    & SearchViewInteraction
    & SearchViewState

@MainActor
protocol SearchViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol SearchViewInteraction: AnyObject {
    func handleTextEvent(_ event: SearchViewTextEvent)
    func handleActionEvent(_ event: SearchViewActionEvent)
}

@MainActor
protocol SearchViewState: ErrorDisplayCompatible {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SearchViewSectionWrapper, SearchViewItemlWrapper>

    var onSnapshotWasPrepared: ((Snapshot) -> Void)? { get set }
    var onSearchInputWasPrepared: ((SearchViewInput) -> Void)? { get set }
}

// MARK: - Model
// sourcery: AutoMockable
protocol SearchModelProtocol: AnyObject {
    func fetchFeedingPoints(force: Bool) async throws -> [SearchModelSection]
    func filterFeedingPoints(_ searchString: String?) async -> [SearchModelSection]

    func toogleFeedingPoint(forIdentifier identifier: String)
}

// MARK: - Coordinator
protocol SearchCoordinatable: Coordinatable {
    func move(to route: SearchRoute)
}
