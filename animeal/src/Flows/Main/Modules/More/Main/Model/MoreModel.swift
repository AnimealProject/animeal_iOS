import Foundation

final class MoreModel: MoreModelProtocol {

    // MARK: - Initialization
    init() { }

    // MARK: - Requests
    func fetchActions() -> [MoreActionModel] {
        var actions = [
            MoreActionModel(type: .profilePage, title: L10n.More.profilePage),
            MoreActionModel(type: .faq, title: L10n.More.faq),
            MoreActionModel(type: .donate, title: L10n.More.donate),
            MoreActionModel(type: .about, title: L10n.More.aboutShort),
            MoreActionModel(type: .termsAndConditions, title: L10n.Action.termsAndConditions),
            MoreActionModel(type: .privacyPolicy, title: L10n.Action.privacyPolicy),
            MoreActionModel(type: .account, title: L10n.More.account)
        ]
        #if DEBUG
        actions.append(MoreActionModel(type: .qaMenu, title: L10n.More.qaMenu))
        #endif
        return actions
    }
}
