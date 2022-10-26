import Foundation

final class MoreViewModel: MoreViewModelLifeCycle, MoreViewInteraction, MoreViewState {

    // MARK: - Dependencies
    private let model: MoreModelProtocol
    private let coordinator: MoreCoordinatable
    private let mapper: MoreItemViewMappable

    // MARK: - State
    var onActionsHaveBeenPrepared: (([MoreItemView]) -> Void)?

    // MARK: - Initialization
    init(
        coordinator: MoreCoordinatable,
        mapper: MoreItemViewMappable = MoreItemViewMapper(),
        model: MoreModelProtocol
    ) {
        self.coordinator = coordinator
        self.mapper = mapper
        self.model = model
    }

    // MARK: - Life cycle
    func load() {
        let actions = model.fetchActions()
        onActionsHaveBeenPrepared?(
            actions.map {
                mapper.mapActionModel($0)
            }
        )
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: MoreViewActionEvent) {
        switch event {
        case .tapInside(let identifier):
            guard let route = MoreRoute(rawValue: identifier) else {
                return
            }
            coordinator.routeTo(route)
        }
    }
}
