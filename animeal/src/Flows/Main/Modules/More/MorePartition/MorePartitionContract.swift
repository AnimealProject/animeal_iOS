import UIKit

// MARK: - View
protocol MorePartitionViewable: AnyObject {
    func applyContentModel(_ model: PartitionContentModel)
}

// MARK: - ViewModel
typealias MorePartitionViewModelProtocol = MorePartitionViewModelLifeCycle
    & MorePartitionViewInteraction
    & MorePartitionViewState

protocol MorePartitionViewModelLifeCycle: AnyObject {
    func load()
}

@MainActor
protocol MorePartitionViewInteraction: AnyObject {
    func handleActionEvent(_ event: MorePartitionViewActionEvent)
}

@MainActor
protocol MorePartitionViewState: AnyObject {
    var onContentHaveBeenPrepared: ((PartitionContentModel) -> Void)? { get set }
}

// MARK: - Model
protocol MorePartitionModelProtocol: AnyObject {
    func fetchContentModel(_ mode: PartitionMode) -> PartitionContentModel

    func handleSignOut(completion: ((Result<Void, Error>) -> Void)?)
    func handleDeleteUser(completion: ((Result<Void, Error>) -> Void)?)
    func handleCopyIBAN()
}

// MARK: - Coordinator
@MainActor
protocol MorePartitionCoordinatable: Coordinatable, AlertCoordinatable {
    func routeTo(_ route: MorePartitionRoute)
}

// MARK: - Enums
enum MorePartitionRoute {
    case error(String)
    case deleteUser
    case back
    case profilePage
}

enum MorePartitionViewActionEvent {
    case deleteAccount
    case back
    case copyIBAN
    case profilePage
}
