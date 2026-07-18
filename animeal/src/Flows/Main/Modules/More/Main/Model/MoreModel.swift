import Foundation
import Services

final class MoreModel: MoreModelProtocol {

    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let seenTracker: FeedingsSeenTrackerProtocol

    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol = AppDelegate.shared.context.networkService,
        seenTracker: FeedingsSeenTrackerProtocol = FeedingsSeenTracker()
    ) {
        self.networkService = networkService
        self.seenTracker = seenTracker
    }

    // MARK: - Requests
    func fetchActions() -> [MoreActionModel] {
        var actions = [
            MoreActionModel(type: .profilePage, title: L10n.More.profilePage),
            MoreActionModel(type: .feedings, title: L10n.More.feedings),
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

    func hasUnseenPendingFeedings() async -> Bool {
        guard let pendingFeedings = try? await networkService.query(
            request: .getActiveFeedings(status: FeedingStatus.pending.rawValue)
        ) else {
            return false
        }
        return seenTracker.hasUnseen(among: pendingFeedings.map(\.id))
    }
}
