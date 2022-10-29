import Foundation

// MARK: - View
@MainActor
protocol ProfileViewable: ActivityDisplayable, ErrorDisplayable {
    func applyHeader(_ viewHeader: ProfileViewHeader)
    func applyItems(_ viewItems: [ProfileViewItem])
    func applyActions(_ viewActions: [ProfileViewAction])
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
}

@MainActor
protocol ProfileViewState: ActivityDisplayCompatible {
    var onHeaderHasBeenPrepared: ((ProfileViewHeader) -> Void)? { get set }
    var onItemsHaveBeenPrepared: (([ProfileViewItem]) -> Void)? { get set }
    var onActionsHaveBeenPrepared: (([ProfileViewAction]) -> Void)? { get set }
}

// MARK: - Model
protocol ProfileModelProtocol {
    func fetchPlaceholderItems() -> [ProfileModelItem]
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
protocol ProfileCoordinatable: Coordinatable {
    func move(to route: ProfileRoute)
}
