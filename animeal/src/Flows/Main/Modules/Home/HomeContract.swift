import Foundation

// MARK: - View
protocol HomeViewModelOutput: AnyObject {
    func applyFeedingPoints(_ feedingPoints: [FeedingPointViewItem])
    func applyFilter(_ filter: FilterModel)
}

// MARK: - Model

// sourcery: AutoMockable
protocol HomeModelProtocol: AnyObject {
    func fetchFeedingPoints(_ completion: (([HomeModel.FeedingPoint]) -> Void)?)
    func fetchFilterItems(_ completion: (([HomeModel.FilterItem]) -> Void)?)

    func proceedFilter(_ identifier: HomeModel.FilterItemIdentifier)
}

// MARK: - ViewModel
typealias HomeCombinedViewModel = HomeViewModelLifeCycle
    & HomeViewInteraction
    & HomeViewState

protocol HomeViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol HomeViewInteraction: AnyObject {
    func handleActionEvent(_ event: HomeViewActionEvent)
}

protocol HomeViewState: AnyObject {
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)? { get set }
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)? { get set }
}

enum HomeViewActionEvent {
    case tapFeedingPoint(String)
    case tapFilterControl(Int)
}
