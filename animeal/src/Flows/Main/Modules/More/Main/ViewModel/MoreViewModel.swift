import Foundation
import Services

final class MoreViewModel: MoreViewModelLifeCycle, MoreViewInteraction, MoreViewState {

    // MARK: - Dependencies
    private let model: MoreModelProtocol
    private let coordinator: MoreCoordinatable
    private let mapper: MoreItemViewMappable
    private let userProfileService: UserProfileServiceProtocol
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - State
    var onSectionsHaveBeenPrepared: (([MoreSectionView]) -> Void)?
    var onLogoutVisibilityHaveBeenPrepared: ((Bool) -> Void)?

    // MARK: - Initialization
    init(
        coordinator: MoreCoordinatable,
        mapper: MoreItemViewMappable = MoreItemViewMapper(),
        model: MoreModelProtocol,
        userProfileService: UserProfileServiceProtocol,
        authenticationService: AuthenticationServiceProtocol
    ) {
        self.coordinator = coordinator
        self.mapper = mapper
        self.model = model
        self.userProfileService = userProfileService
        self.authenticationService = authenticationService
    }

    // MARK: - Life cycle
    func load() {
        let sections = visibleSections(from: model.fetchSections())
        render(sections, hasUnseenFeedings: false)
        onLogoutVisibilityHaveBeenPrepared?(!isGuest)

        guard canModerate else { return }

        Task { @MainActor in
            guard await self.model.hasUnseenPendingFeedings() else { return }
            self.render(sections, hasUnseenFeedings: true)
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
        case .logout:
            Task { @MainActor in
                do {
                    try await self.authenticationService.signOut()
                    self.coordinator.routeTo(.logout)
                } catch {
                    self.coordinator.routeTo(.error(error.localizedDescription))
                }
            }
        }
    }

    func canRouteTo(route: MoreRoute) -> Bool {
        guard userProfileService.getCurrentUserValidationModel().userMode == .guest else {
            if case .feedings = route {
                return canModerate
            }
            return true
        }

        switch route {
        case .feedings, .account, .logout:
            return false
        case .donate, .faq, .about, .alert, .error:
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

    private var isGuest: Bool {
        userProfileService.getCurrentUserValidationModel().userMode == .guest
    }

    private var canModerate: Bool {
        let roles = userProfileService.getCurrentUserValidationModel().roles
        return roles.contains(.admin) || roles.contains(.moderator)
    }

    private func visibleSections(from sections: [MoreSectionModel]) -> [MoreSectionModel] {
        sections.compactMap { section in
            let actions = section.actions.filter { $0.type != .feedings || canModerate }
            guard !actions.isEmpty else { return nil }
            return MoreSectionModel(title: section.title, actions: actions)
        }
    }

    private func render(_ sections: [MoreSectionModel], hasUnseenFeedings: Bool) {
        onSectionsHaveBeenPrepared?(
            sections.map { mapper.mapSection($0, hasUnseenFeedings: hasUnseenFeedings) }
        )
    }
}

extension MoreViewModel {
    enum AccessibilityID {
        static let screen = "more_screen"
        static let list = "list"
        static let logoutButton = "logout_button"
        static let alertConfirm = "alert_confirm"
        static let alertCancel = "alert_cancel"
        static let adminToolsHeader = "admin_tools_header"

        static func item(_ id: String) -> String {
            "item_\(id)"
        }
    }
}
