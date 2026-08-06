import Foundation
import Services

final class MoreViewModel: MoreViewModelLifeCycle, MoreViewInteraction, MoreViewState {

    // MARK: - Dependencies
    private let model: MoreModelProtocol
    private let coordinator: MoreCoordinatable
    private let mapper: MoreItemViewMappable
    private let userProfileService: UserProfileServiceProtocol

    // MARK: - State
    var onActionsHaveBeenPrepared: (([MoreItemView]) -> Void)?

    // MARK: - Initialization
    init(
        coordinator: MoreCoordinatable,
        mapper: MoreItemViewMappable = MoreItemViewMapper(),
        model: MoreModelProtocol,
        userProfileService: UserProfileServiceProtocol
    ) {
        self.coordinator = coordinator
        self.mapper = mapper
        self.model = model
        self.userProfileService = userProfileService
    }

    // MARK: - Life cycle
    func load() {
        let actions = model.fetchActions().filter { action in
            action.type != .feedings || canModerate
        }
        render(actions, hasUnseenFeedings: false)

        guard canModerate else { return }

        Task { @MainActor in
            guard await self.model.hasUnseenPendingFeedings() else { return }
            self.render(actions, hasUnseenFeedings: true)
        }
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: MoreViewActionEvent) {
        switch event {
        case .tapInside(let identifier):
            guard let route = MoreRoute(rawValue: identifier) else {
                return
            }

            guard canRouteTo(route: route) else {
                coordinator.routeTo(.alert)
                return
            }

            coordinator.routeTo(route)
        }
    }

    func canRouteTo(route: MoreRoute) -> Bool {
        guard userProfileService.getCurrentUserValidationModel().userMode == .guest else {
            return route != .feedings || canModerate
        }

        switch route {
        case .profilePage, .feedings, .account:
            return false
        case .donate, .faq, .about, .alert:
            return true
        case .termsAndConditions:
            return true
        case .privacyPolicy:
            return true
        case .qaMenu:
            return true
        }
    }

    // MARK: - Private

    private var canModerate: Bool {
        let roles = userProfileService.getCurrentUserValidationModel().roles
        return roles.contains(.admin) || roles.contains(.moderator)
    }

    private func render(_ actions: [MoreActionModel], hasUnseenFeedings: Bool) {
        onActionsHaveBeenPrepared?(
            actions.map {
                mapper.mapActionModel($0, hasIndicator: $0.type == .feedings && hasUnseenFeedings)
            }
        )
    }
}
