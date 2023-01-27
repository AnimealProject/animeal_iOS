import UIKit

// MARK: - View
protocol AboutViewable: AnyObject {
}

// MARK: - ViewModel
typealias AboutViewModelProtocol = AboutViewModelLifeCycle
    & AboutViewInteraction
    & AboutViewState

protocol AboutViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol AboutViewInteraction: AnyObject {
    func handleActionEvent(_ event: AboutViewActionEvent)
}

protocol AboutViewState: AnyObject {
    var observableModel: AboutModelProtocol { get }
}

// MARK: - Model

// sourcery: AutoMockable
protocol AboutModelProtocol: AnyObject {
    var contentText: String { get set }
    var links: [AboutLink] { get set }
}

// MARK: - Actions
enum AboutViewActionEvent {
    case back
    case linkTapped(AboutLink)
}
