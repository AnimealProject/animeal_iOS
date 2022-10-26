import Foundation

final class FeedingBookingViewModel: FeedingBookingViewModelLifeCycle, FeedingBookingViewInteraction, FeedingBookingViewState {

    // MARK: - Dependencies
    private let model: FeedingBookingModelProtocol
    private let coordinator: FeedingBookingCoordinatable

    // MARK: - Initialization
    init(
        model: FeedingBookingModelProtocol,
        coordinator: FeedingBookingCoordinatable
    ) {
        self.model = model
        self.coordinator = coordinator
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
    }

    func handleActionEvent(_ event: FeedingBookingEvent) {
        switch event {
        case .cancel, .agree:
            coordinator.routeTo(.dismiss)
        }
    }
}
