import UIKit

// MARK: - View
protocol FeedingPointDetailsViewable: AnyObject {
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
}

protocol FeedingPointDetailsViewState: AnyObject {
}

// MARK: - Model

// sourcery: AutoMockable
protocol FeedingPointDetailsModelProtocol: AnyObject {
}
