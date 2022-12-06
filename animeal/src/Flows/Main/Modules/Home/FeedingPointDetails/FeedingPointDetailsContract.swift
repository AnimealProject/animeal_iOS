import UIKit
import CoreLocation

// MARK: - View
protocol FeedingPointDetailsViewable: AnyObject {
    func applyFeedingPointContent(_ content: FeedingPointDetailsViewItem)
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
    var onContentHaveBeenPrepared: ((FeedingPointDetailsViewItem) -> Void)? { get set }
    var onMediaContentHaveBeenPrepared: ((FeedingPointMediaContent) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol FeedingPointDetailsModelProtocol: AnyObject {
    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?)
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?)
}

typealias FeedingPointCoordinates = CLLocationCoordinate2D

// sourcery: AutoMockable
protocol FeedingPointDetailsDataStoreProtocol: AnyObject {
    var feedingPointCoordinates: FeedingPointCoordinates { get }
}

// MARK: - Coordinator
protocol FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute)
}

// MARK: - Models
enum FeedingPointRoute {
    case feed(FeedingPointFeedDetails)
}

struct FeedingPointFeedDetails {
    let coordinates: FeedingPointCoordinates
}

enum FeedingPointEvent {
    case tapAction
}
