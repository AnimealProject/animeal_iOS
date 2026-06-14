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

@MainActor
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
@MainActor
protocol MoreCoordinatable: Coordinatable {
    func routeTo(_ route: MoreRoute)
}

// MARK: - Enums
enum MoreRoute {
    case profilePage
    case faq
    case donate
    case about
    case alert
    case termsAndConditions
    case privacyPolicy
    case account
    case qaMenu

    init?(rawValue: String) {
        switch rawValue {
        case MoreActionType.profilePage.rawValue:
            self = .profilePage
        case MoreActionType.faq.rawValue:
            self = .faq
        case MoreActionType.donate.rawValue:
            self = .donate
        case MoreActionType.about.rawValue:
            self = .about
        case MoreActionType.termsAndConditions.rawValue:
            self = .termsAndConditions
        case MoreActionType.privacyPolicy.rawValue:
            self = .privacyPolicy
        case MoreActionType.account.rawValue:
            self = .account
        case MoreActionType.qaMenu.rawValue:
            self = .qaMenu
        default:
            return nil
        }
    }
}

enum MoreViewActionEvent {
    case tapInside(_ identifier: String)
}
