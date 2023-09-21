import Foundation

// MARK: - View
@MainActor
protocol ProfileViewable: AnyObject {
    func applyHeader(_ viewHeader: ProfileViewHeader)
    func applyItemsSnapshot(_ viewItemsSnapshot: ProfileViewItemsSnapshot) 
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
}

@MainActor
protocol ProfileViewInteraction: AnyObject {
    @discardableResult
    func handleItemEvent(_ event: ProfileViewItemEvent) -> ProfileViewText
    func handleActionEvent(_ event: ProfileViewActionEvent)
    func handleBackButton()
}

@MainActor
protocol ProfileViewState: AnyObject {
    var onHeaderHasBeenPrepared: ((ProfileViewHeader) -> Void)? { get set }
    var onItemsHaveBeenPrepared: ((ProfileViewItemsSnapshot) -> Void)? { get set }
    var onActionsHaveBeenPrepared: (([ProfileViewAction]) -> Void)? { get set }
    var onConfigurationHasBeenPrepared: ((ProfileViewConfiguration) -> Void)? { get set }
}

// MARK: - Model
protocol ProfileModelProtocol {
    func fetchCachedItems() async throws -> [ProfileModelItem]
    func fetchItems() async throws -> [ProfileModelItem]
    func fetchItem(_ identifier: String) async -> ProfileModelItem?
    func updateItem(_ text: String?, forIdentifier identifier: String) async
    func validateItems() async -> Bool

    func fetchRequiredAction(forIdentifier identifier: String) async -> PhoneModelRequiredAction?

    func fetchActions() async -> [ProfileModelAction]
    func executeAction(_ identifier: String) async throws -> ProfileModelIntermediateStep?
    func proceedAction(_ identifier: String) async throws -> ProfileModelNextStep
    func discardAction() async throws -> [ProfileModelAction]
}

// MARK: - Coordinator
protocol ProfileCoordinatable: Coordinatable, AlertCoordinatable, ActivityDisplayable {
    func move(to route: ProfileRoute)
}
