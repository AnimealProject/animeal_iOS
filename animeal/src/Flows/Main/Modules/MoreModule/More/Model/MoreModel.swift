import Foundation

final class MoreModel: MoreModelProtocol {

    // MARK: - Initialization
    init() { }

    // MARK: - Requests
    func fetchActions() -> [MoreActionModel] {
        return [
            MoreActionModel(type: .profilePage, title: L10n.More.profilePage),
            MoreActionModel(type: .donate, title: L10n.More.donate),
            MoreActionModel(type: .help, title: L10n.More.help),
            MoreActionModel(type: .about, title: L10n.More.about),
            MoreActionModel(type: .account, title: L10n.More.account)
        ]
    }
}
