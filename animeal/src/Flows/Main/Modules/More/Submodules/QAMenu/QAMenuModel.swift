import Foundation

// MARK: - QAMenuModel
final class QAMenuModel: QAMenuModelProtocol, ObservableObject {

    // MARK: - Published properties
    @Published var isLoadAllFeedingPointsEnabled: Bool

    // MARK: - Initialization
    init(isLoadAllFeedingPointsEnabled: Bool = false) {
        self.isLoadAllFeedingPointsEnabled = isLoadAllFeedingPointsEnabled
    }
}
