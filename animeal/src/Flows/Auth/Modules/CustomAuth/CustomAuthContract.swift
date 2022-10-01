// MARK: - View
@MainActor
protocol CustomAuthViewable: ActivityDisplayable, ErrorDisplayable {
    func applyHeader(_ viewHeader: CustomAuthViewHeader)
    func applyItems(_ viewItems: [CustomAuthViewItem])
}

// MARK: - ViewModel
typealias CustomAuthViewModelProtocol = CustomAuthViewModelLifeCycle
    & CustomAuthViewInteraction
    & CustomAuthViewState

protocol CustomAuthViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol CustomAuthViewInteraction: AnyObject {
    @discardableResult
    func handleTextEvent(_ event: CustomAuthViewTextEvent) -> CustomAuthViewText
    func handleActionEvent(_ event: CustomAuthViewActionEvent)
}

@MainActor
protocol CustomAuthViewState: ActivityDisplayCompatible {
    var onHeaderHasBeenPrepared: ((CustomAuthViewHeader) -> Void)? { get set }
    var onItemsHaveBeenPrepared: (([CustomAuthViewItem]) -> Void)? { get set }
    var onActionsHaveBeenPrepared: (([CustomAuthViewAction]) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol CustomAuthModelProtocol: AnyObject {
    func fetchItems() -> [CustomAuthModelItem]
    func fetchItem(_ identifier: String) -> CustomAuthModelItem?
    func updateItem(_ text: String?, forIdentifier identifier: String)

    func clearErrors()
    func validate() -> Bool
    func authenticate() async throws -> CustomAuthModelNextStep
}

// MARK: - Coordinator
protocol CustomAuthCoordinatable: Coordinatable {
    func moveFromCustomAuth(to route: CustomAuthRoute)
}
