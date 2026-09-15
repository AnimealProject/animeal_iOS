import Foundation
import Amplify

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
        model.backendSummary = QAMenuStrings.backendSummary(
            environment: BackendEnvironment.activeName,
            host: BackendEnvironment.apiHost ?? QAMenuStrings.unknownHost
        )
        model.backendEnvironment = BackendEnvironment.active
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

        case let .selectBackendEnvironment(environment):
            switchBackendEnvironment(to: environment)
        }
    }

    // MARK: - Private
    private func switchBackendEnvironment(to environment: BackendEnvironment) {
        #if QA_MENU
        guard environment != BackendEnvironment.active else { return }
        model.backendEnvironment = environment
        Task {
            BackendEnvironment.runtimeOverride = environment
            try? await Amplify.DataStore.clear()
            _ = await Amplify.Auth.signOut()
            await MainActor.run { exit(0) }
        }
        #endif
    }
}
