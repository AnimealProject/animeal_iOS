import UIKit

final class MorePartitionViewModel: MorePartitionViewModelLifeCycle,
                                    MorePartitionViewInteraction,
                                    MorePartitionViewState {
    // MARK: - Dependencies
    private let model: MorePartitionModelProtocol
    private let mode: PartitionMode
    private let coordinator: MorePartitionCoordinatable

    var onContentHaveBeenPrepared: ((PartitionContentModel) -> Void)?

    // MARK: - Initialization
    init(
        model: MorePartitionModelProtocol,
        mode: PartitionMode,
        coordinator: MorePartitionCoordinatable
    ) {
        self.model = model
        self.mode = mode
        self.coordinator = coordinator
    }

    // MARK: - Life cycle
    func load() {
        let contentModel = model.fetchContentModel(mode)
        onContentHaveBeenPrepared?(contentModel)
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: MorePartitionViewActionEvent) {
        switch event {
        case .logout:
            model.handleSignOut { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.coordinator.routeTo(.logout)
                case .failure(let error):
                    self.coordinator.routeTo(.error(error.localizedDescription))
                }
            }
        case .deleteAccount:
            self.model.handleDeleteUser { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.coordinator.routeTo(.deleteUser)
                case .failure(let error):
                    self.coordinator.routeTo(.error(error.localizedDescription))
                }
            }
        case .back:
            coordinator.routeTo(.back)
        case .copyIBAN:
            model.handleCopyIBAN()
        }
    }
}
