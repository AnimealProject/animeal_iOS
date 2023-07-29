import UIKit
import CoreLocation
import UIComponents

// MARK: - View
@MainActor
protocol FeedingPointDetailsViewable: AnyObject {
    func applyFeedingPointContent(_ content: FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem)
}

// MARK: - ViewModel
typealias FeedingPointDetailsViewModelProtocol = FeedingPointDetailsViewModelLifeCycle
    & FeedingPointDetailsViewInteraction
    & FeedingPointDetailsViewState

@MainActor
protocol FeedingPointDetailsViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol FeedingPointDetailsViewInteraction: AnyObject {
    func handleActionEvent(_ event: FeedingPointEvent)
}

@MainActor
protocol FeedingPointDetailsViewState: AnyObject {
    var onRequestLocationAccess: (() -> Void)? { get set }
    var onContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem) -> Void)? { get set }
    var onFeedingHistoryHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointFeeders) -> Void)? { get set }
    var onMediaContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointMediaContent) -> Void)? { get set }
    var onFavoriteMutationFailed: (() -> Void)? { get set }
    var onFavoriteMutation: (() -> Void)? { get set }
    var showOnMapAction: ButtonView.Model? { get }
    var shimmerScheduler: ShimmerViewScheduler { get }
    var historyInitialized: Bool { get }
}

// MARK: - Model

// sourcery: AutoMockable
protocol FeedingPointDetailsModelProtocol: AnyObject {
    var onFeedingPointChange: ((FeedingPointDetailsModel.PointContent, Bool) -> Void)? { get set }

    func fetchFeedingPoint(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?)
    func fetchFeedingHistory(_ completion: (([FeedingPointDetailsModel.Feeder]) -> Void)?)
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?)
    func mutateFavorite() async throws -> Bool
}

// sourcery: AutoMockable
protocol FeedingPointDetailsDataStoreProtocol: AnyObject {
    var feedingPointId: String { get }
    var feedingPointLocation: CLLocationCoordinate2D { get }
}

// MARK: - Coordinator
protocol FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute)
}

// MARK: - Models
enum FeedingPointRoute {
    case feed(FeedingPointFeedDetails)
    case map(identifier: String)
}

struct FeedingPointFeedDetails {
    let identifier: String
    let coordinates: CLLocationCoordinate2D
}

enum FeedingPointEvent {
    case tapAction
    case tapFavorite
    case tapShowOnMap
    case tapCancelLocationRequest
}
