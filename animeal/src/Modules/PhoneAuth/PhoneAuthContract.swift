// MARK: - View
protocol PhoneAuthViewable: AnyObject {
    func applyHeader(_ viewHeader: PhoneAuthViewHeader)
    func applyItems(_ viewItems: [PhoneAuthViewItem])
}

// MARK: - ViewModel
typealias PhoneAuthViewModelProtocol = PhoneAuthViewModelLifeCycle
    & PhoneAuthViewInteraction
    & PhoneAuthViewState

protocol PhoneAuthViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

protocol PhoneAuthViewInteraction: AnyObject {
    @discardableResult
    func handleTextEvent(_ event: PhoneAuthViewTextEvent) -> PhotoAuthViewText
    func handleReturnTapped()
}

protocol PhoneAuthViewState: AnyObject {
    var onHeaderHasBeenPrepared: ((PhoneAuthViewHeader) -> Void)? { get set }
    var onItemsHaveBeenPrepared: (([PhoneAuthViewItem]) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol PhoneAuthModelProtocol: AnyObject {
    var fetchItemsResponse: (([PhoneAuthModelItem]) -> Void)? { get set }
    var proceedAuthenticationResponse: ((Result<PhoneAuthModelNextStep, Error>) -> Void)? { get set }
    
    func fetchItems()
    func fetchItem(_ identifier: String) -> PhoneAuthModelItem?
    
    func validateItems() -> Bool
    
    func updateItem(_ text: String?, forIdentifier identifier: String)
    
    func proceedAuthentication()
}

// MARK: - Coordinator
protocol PhoneAuthCoordinatable: Coordinatable {
    func move(_ route: PhoneAuthRoute)
}
