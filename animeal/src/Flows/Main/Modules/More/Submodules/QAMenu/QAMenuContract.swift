import UIKit

// MARK: - View
protocol QAMenuViewable: AnyObject {
}

// MARK: - ViewModel
typealias QAMenuViewModelProtocol = QAMenuViewModelLifeCycle
    & QAMenuViewInteraction
    & QAMenuViewState

protocol QAMenuViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol QAMenuViewInteraction: AnyObject {
    func handleActionEvent(_ event: QAMenuViewActionEvent)
}

protocol QAMenuViewState: AnyObject {
    var observableModel: QAMenuModelProtocol { get }
}

// MARK: - Model

// sourcery: AutoMockable
protocol QAMenuModelProtocol: AnyObject {
    var isLoadAllFeedingPointsEnabled: Bool { get set }
    var backendSummary: String { get set }
    var backendEnvironment: BackendEnvironment? { get set }
    var backendEnvironments: [BackendEnvironment] { get }
}

// MARK: - Actions
enum QAMenuViewActionEvent {
    case back
    case toggleLoadAllFeedingPoints(Bool)
    case selectBackendEnvironment(BackendEnvironment)
}
