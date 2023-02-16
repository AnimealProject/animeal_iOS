import UIKit

// MARK: - View
protocol FeedingFinishedViewable: AnyObject {
}

// MARK: - ViewModel
typealias FeedingFinishedViewModelProtocol = FeedingFinishedViewModelLifeCycle
    & FeedingFinishedViewInteraction
    & FeedingFinishedViewState

protocol FeedingFinishedViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol FeedingFinishedViewInteraction: AnyObject {
    func handleActionEvent(_ event: FeedingFinishedEvent)
}

protocol FeedingFinishedViewState: AnyObject {
    var observableModel: FeedingFinishedModelProtocol { get }
}

// MARK: - Coordinator
protocol FeedingFinishedCoordinatable {
    func routeTo(_ route: FeedingFinishedRoute)
}

// MARK: - Model
enum FeedingFinishedRoute {
    case backToHome
}

enum FeedingFinishedEvent {
    case backToHome
}

// sourcery: AutoMockable
protocol FeedingFinishedModelProtocol: AnyObject {
}
