import UIKit
import CoreLocation
import UIComponents

// MARK: - View
protocol FeedingPointDetailsViewable: AnyObject {
    func applyFeedingPointContent(_ content: FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem)
}

// MARK: - ViewModel
typealias FeedingPointDetailsViewModelProtocol = FeedingPointDetailsViewModelLifeCycle
    & FeedingPointDetailsViewInteraction
    & FeedingPointDetailsViewState

protocol FeedingPointDetailsViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol FeedingPointDetailsViewInteraction: AnyObject {
    func handleActionEvent(_ event: FeedingPointEvent)
}

protocol FeedingPointDetailsViewState: AnyObject {
    var onContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem) -> Void)? { get set }
    var onMediaContentHaveBeenPrepared: ((FeedingPointDetailsViewMapper.FeedingPointMediaContent) -> Void)? { get set }
    var onFavoriteMutationFailed: (() -> Void)? { get set }
    var showOnMapAction: ButtonView.Model? { get }
}

// MARK: - Model

// sourcery: AutoMockable
protocol FeedingPointDetailsModelProtocol: AnyObject {
    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?)
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?)
    func mutateFavorite(completion: ((Bool) -> Void)?)
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
}
