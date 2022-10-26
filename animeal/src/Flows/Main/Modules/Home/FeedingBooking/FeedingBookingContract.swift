import UIKit

// MARK: - View
protocol FeedingBookingViewable: AnyObject {
}

// MARK: - ViewModel
typealias FeedingBookingViewModelProtocol = FeedingBookingViewModelLifeCycle
    & FeedingBookingViewInteraction
    & FeedingBookingViewState

protocol FeedingBookingViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol FeedingBookingViewInteraction: AnyObject {
    func handleActionEvent(_ event: FeedingBookingEvent)
}

protocol FeedingBookingViewState: AnyObject {
}

// MARK: - Model

// sourcery: AutoMockable
protocol FeedingBookingModelProtocol: AnyObject {
}

// MARK: - Coordinator
protocol FeedingBookingCoordinatable {
    func routeTo(_ route: FeedingBookingRoute)
}

// MARK: - Models
enum FeedingBookingRoute {
    case dismiss
}

enum FeedingBookingEvent {
    case cancel
    case agree
}
