import UIKit

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

// MARK: - Coordinator
protocol FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute)
}

// MARK: - Models
enum FeedingPointRoute {
    case dismiss
}

enum FeedingPointEvent {
    case tapAction
}
