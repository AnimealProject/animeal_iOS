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
    func fetchSections() -> [MoreSectionModel] {
        var adminActions = [
            MoreActionModel(type: .feedings, title: L10n.More.feedings)
        ]
        #if QA_MENU
        adminActions.append(MoreActionModel(type: .qaMenu, title: L10n.More.qaMenu))
        #endif

        return [
            MoreSectionModel(
                title: nil,
                actions: [
                    MoreActionModel(type: .account, title: L10n.More.account)
                ]
            ),
            MoreSectionModel(
                title: nil,
                actions: [
                    MoreActionModel(type: .termsAndConditions, title: L10n.Action.termsAndConditions),
                    MoreActionModel(type: .privacyPolicy, title: L10n.Action.privacyPolicy),
                    MoreActionModel(type: .about, title: L10n.More.aboutShort)
                ]
            ),
            MoreSectionModel(
                title: nil,
                actions: [
                    MoreActionModel(type: .faq, title: L10n.More.faq),
                    MoreActionModel(type: .donate, title: L10n.More.donate)
                ]
            ),
            MoreSectionModel(
                title: L10n.More.adminTools,
                actions: adminActions
            )
        ]
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
