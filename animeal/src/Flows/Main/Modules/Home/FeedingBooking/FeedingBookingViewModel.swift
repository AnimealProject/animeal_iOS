import Foundation

final class FeedingBookingViewModel: FeedingBookingViewModelLifeCycle,
                                     FeedingBookingViewInteraction,
                                     FeedingBookingViewState {
    // MARK: - Dependencies
    private let model: FeedingBookingModelProtocol
    private let coordinator: FeedingBookingCoordinatable
    private let feedingDetails: FeedingPointFeedDetails

    // MARK: - Initialization
    init(
        model: FeedingBookingModelProtocol,
        coordinator: FeedingBookingCoordinatable,
        feedingDetails: FeedingPointFeedDetails
    ) {
        self.model = model
        self.coordinator = coordinator
        self.feedingDetails = feedingDetails
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
    }

    func handleActionEvent(_ event: FeedingBookingEvent) {
        switch event {
        case .cancel:
            coordinator.routeTo(.cancel)
        case .agree:
            // TODO: Handle feeding request here
            coordinator.routeTo(.agree(feedingDetails))
        }
    }
}
