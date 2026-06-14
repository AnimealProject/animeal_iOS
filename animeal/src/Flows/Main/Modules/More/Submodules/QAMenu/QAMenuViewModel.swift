import Foundation

final class QAMenuViewModel: QAMenuViewModelLifeCycle, QAMenuViewInteraction, QAMenuViewState {

    // MARK: - Dependencies
    private let model: QAMenuModelProtocol
    private let coordinator: MorePartitionCoordinatable

    // MARK: - Initialization
    init(
        model: QAMenuModelProtocol,
        coordinator: MorePartitionCoordinatable
    ) {
        self.model = model
        self.coordinator = coordinator
        setup()
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        model.isLoadAllFeedingPointsEnabled = FeatureFlags.isLoadAllFeedingPointsEnabled
    }

    var observableModel: QAMenuModelProtocol {
        return model
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: QAMenuViewActionEvent) {
        switch event {
        case .back:
            coordinator.routeTo(.back)

        case let .toggleLoadAllFeedingPoints(isOn):
            FeatureFlags.isLoadAllFeedingPointsEnabled = isOn
            model.isLoadAllFeedingPointsEnabled = isOn
        }
    }
}
