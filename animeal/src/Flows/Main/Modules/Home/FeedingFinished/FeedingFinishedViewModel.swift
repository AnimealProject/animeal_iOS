import Foundation

final class FeedingFinishedViewModel: FeedingFinishedViewModelLifeCycle, FeedingFinishedViewInteraction, FeedingFinishedViewState {

    // MARK: - Dependencies
    private let model: FeedingFinishedModelProtocol
    private let coordinator: FeedingFinishedCoordinatable

    // MARK: - Initialization
    init(
        model: FeedingFinishedModelProtocol,
        coordinator: FeedingFinishedCoordinatable

    ) {
        self.model = model
        self.coordinator = coordinator
        setup()
    }

    public var observableModel: FeedingFinishedModelProtocol {
        return model
    }

    func handleActionEvent(_ event: FeedingFinishedEvent) {
        switch event {
        case .backToHome:
            coordinator.routeTo(.backToHome)
        }
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
    }
}
