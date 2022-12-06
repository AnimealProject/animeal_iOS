import Foundation
import CoreLocation

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
    func proceedFeedingPointSelection(_ identifier: String, completion: (([HomeModel.FeedingPoint]) -> Void)?)
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
    var onRouteRequestHaveBeenPrepared: ((CLLocationCoordinate2D) -> Void)? { get set }
}

enum HomeViewActionEvent {
    case tapFeedingPoint(String)
    case tapFilterControl(Int)
}

// MARK: - Coordinator
protocol HomeCoordinatable {
    func routeTo(_ route: HomeRoute)
}

protocol HomeCoordinatorEventHandlerProtocol {
    var feedingDidStartedEvent: ((FeedingPointFeedDetails) -> Void)? { get set }
}

enum HomeRoute {
    case details(String)
}
