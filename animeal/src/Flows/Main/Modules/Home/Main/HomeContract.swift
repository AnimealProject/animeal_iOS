import Foundation
import CoreLocation

// MARK: - View
@MainActor
protocol HomeViewModelOutput: AnyObject {
    func applyFeedingPoints(_ feedingPoints: [FeedingPointViewItem])
    func applyFilter(_ filter: FilterModel)
}

// MARK: - Model

// sourcery: AutoMockable
protocol HomeModelProtocol: AnyObject {
    func fetchFeedingPoints() async throws -> [HomeModel.FeedingPoint]
    func fetchFilterItems(_ completion: (([HomeModel.FilterItem]) -> Void)?)
    func fetchFeedingAction(request: HomeModel.FeedingActionRequest) -> HomeModel.FeedingAction
    func fetchFeedingPoint(_ pointId: String) async throws -> HomeModel.FeedingPoint

    func proceedFilter(_ identifier: HomeModel.FilterItemIdentifier)
    func proceedFeedingPointSelection(_ identifier: String, completion: (([HomeModel.FeedingPoint]) -> Void)?)

    // Feeding flow
    func processStartFeeding(feedingPointId: String) async throws -> FeedingResponse
    @discardableResult
    func processCancelFeeding() async throws -> FeedingResponse
    func processFinishFeeding(imageKeys: [String]) async throws -> FeedingResponse
    func fetchFeedingSnapshot() -> FeedingSnapshot?
}

// MARK: - ViewModel
typealias HomeCombinedViewModel = HomeViewModelLifeCycle
    & HomeViewInteraction
    & HomeViewState

@MainActor
protocol HomeViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol HomeViewInteraction: AnyObject {
    func handleActionEvent(_ event: HomeViewActionEvent)
    func fetchUnfinishedFeeding()
    func startFeeding(feedingPointId id: String)
    func finishFeeding(imageKeys: [String])
}

@MainActor
protocol HomeViewState: AnyObject {
    var onFeedingPointsHaveBeenPrepared: (([FeedingPointViewItem]) -> Void)? { get set }
    var onFeedingPointCameraMoveRequired: ((FeedingPointCameraMove) -> Void)? { get set }
    var onSegmentsHaveBeenPrepared: ((FilterModel) -> Void)? { get set }
    var onRouteRequestHaveBeenPrepared: ((FeedingPointRouteRequest) -> Void)? { get set }
    var onFeedingActionHaveBeenPrepared: ((FeedingActionMapper.FeedingAction) -> Void)? { get set }
    var onFeedingHaveBeenCompleted: (() -> Void)? { get set }
}

enum HomeViewActionEvent {
    case tapFeedingPoint(String)
    case tapFilterControl(Int)
    case tapCancelFeeding
    case autoCancelFeeding
    case confirmCancelFeeding
}

// MARK: - Coordinator
protocol HomeCoordinatable: AlertCoordinatable, ActivityDisplayable {
    func routeTo(_ route: HomeRoute)
}

protocol HomeCoordinatorEventHandlerProtocol {
    var feedingDidStartedEvent: ((FeedingPointFeedDetails) -> Void)? { get set }
    var feedingDidFinishEvent: (([String]) -> Void)? { get set }
    var moveToFeedingPointEvent: ((String) -> Void)? { get set }
}

enum HomeRoute {
    case details(String)
    case attachPhoto(String)
    case feedingComplete
}

struct FeedingPointCameraMove {
    let feedingPointCoordinate: CLLocationCoordinate2D
}

struct FeedingPointRouteRequest {
    let feedingPointCoordinates: CLLocationCoordinate2D
    let countdownTime: TimeInterval
    let feedingPointId: String
    let isUnfinishedFeeding: Bool
}

struct FeedingResponse {
    let feedingPoint: String
    let feedingStatus: Status

    enum Status {
        case progress
        case none
    }
}
