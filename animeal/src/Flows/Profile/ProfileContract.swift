import Foundation

// MARK: - View
@MainActor
protocol ProfileViewable: AnyObject {
    func applyHeader(_ viewHeader: ProfileViewHeader)
    func applyItems(_ viewItems: [ProfileViewItem])
    func applyActions(_ viewActions: [ProfileViewAction])
    func applyConfiguration(_ viewConfiguration: ProfileViewConfiguration)
}

// MARK: - ViewModel
typealias ProfileViewModelProtocol = ProfileViewModelLifeCycle
    & ProfileViewInteraction
    & ProfileViewState

protocol ProfileViewModelLifeCycle: AnyObject {
    func setup()
    func load()
    func validate()
}

@MainActor
protocol ProfileViewInteraction: AnyObject {
    @discardableResult
    func handleItemEvent(_ event: ProfileViewItemEvent) -> ProfileViewText
    func handleActionEvent(_ event: ProfileViewActionEvent)
}

@MainActor
protocol ProfileViewState: AnyObject {
    var onHeaderHasBeenPrepared: ((ProfileViewHeader) -> Void)? { get set }
    var onItemsHaveBeenPrepared: (([ProfileViewItem]) -> Void)? { get set }
    var onActionsHaveBeenPrepared: (([ProfileViewAction]) -> Void)? { get set }
    var onConfigurationHasBeenPrepared: ((ProfileViewConfiguration) -> Void)? { get set }
}

// MARK: - Model
protocol ProfileModelProtocol {
    func fetchCachedItems() -> [ProfileModelItem]
    func fetchItems() async throws -> [ProfileModelItem]
    func fetchItem(_ identifier: String) -> ProfileModelItem?
    func updateItem(_ text: String?, forIdentifier identifier: String)
    func validateItems() -> Bool

    func fetchRequiredAction(forIdentifier identifier: String) -> PhoneModelRequiredAction?

    func fetchActions() -> [ProfileModelAction]
    func executeAction(_ identifier: String) -> ProfileModelIntermediateStep?
    func proceedAction(_ identifier: String) async throws -> ProfileModelNextStep
}

// MARK: - Coordinator
protocol ProfileCoordinatable: Coordinatable, AlertCoordinatable, ActivityDisplayable {
    func move(to route: ProfileRoute)
}
