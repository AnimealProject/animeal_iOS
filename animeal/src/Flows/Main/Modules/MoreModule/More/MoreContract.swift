import UIKit

// MARK: - View
protocol MoreViewable: AnyObject {
    func applyActions(_ viewItems: [MoreItemView])
}

// MARK: - ViewModel
typealias MoreViewModelProtocol = MoreViewModelLifeCycle
    & MoreViewInteraction
    & MoreViewState

protocol MoreViewModelLifeCycle: AnyObject {
    func load()
}

protocol MoreViewInteraction: AnyObject {
    func handleActionEvent(_ event: MoreViewActionEvent)
}

protocol MoreViewState: AnyObject {
    var onActionsHaveBeenPrepared: (([MoreItemView]) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol MoreModelProtocol: AnyObject {
    func fetchActions() -> [MoreActionModel]
}

// MARK: - Coordinator
protocol MoreCoordinatable: Coordinatable {
    func routeTo(_ route: MoreRoute)
}

// MARK: - Enums
enum MoreRoute {
    case profilePage
    case donate
    case help
    case about
    case account

    init?(rawValue: String) {
        switch rawValue {
        case MoreActionType.profilePage.rawValue:
            self = .profilePage
        case MoreActionType.donate.rawValue:
            self = .donate
        case MoreActionType.help.rawValue:
            self = .help
        case MoreActionType.about.rawValue:
            self = .about
        case MoreActionType.account.rawValue:
            self = .account
        default:
            return nil
        }
    }
}

enum MoreViewActionEvent {
    case tapInside(_ identifier: String)
}
