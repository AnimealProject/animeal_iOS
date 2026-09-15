import Foundation

// MARK: - QAMenuModel
final class QAMenuModel: QAMenuModelProtocol, ObservableObject {

    // MARK: - Published properties
    @Published var isLoadAllFeedingPointsEnabled: Bool
    @Published var backendSummary: String
    @Published var backendEnvironment: BackendEnvironment?
    let backendEnvironments: [BackendEnvironment]

    // MARK: - Initialization
    init(
        isLoadAllFeedingPointsEnabled: Bool = false,
        backendSummary: String = "",
        backendEnvironment: BackendEnvironment? = nil,
        backendEnvironments: [BackendEnvironment] = []
    ) {
        self.isLoadAllFeedingPointsEnabled = isLoadAllFeedingPointsEnabled
        self.backendSummary = backendSummary
        self.backendEnvironment = backendEnvironment
        self.backendEnvironments = backendEnvironments
    }
}
