import Foundation

final class FeedingPointDetailsViewModel: FeedingPointDetailsViewModelLifeCycle,
                                          FeedingPointDetailsViewInteraction,
                                          FeedingPointDetailsViewState {
    // MARK: - Dependencies
    private let model: FeedingPointDetailsModelProtocol

    // MARK: - Initialization
    init(
        model: FeedingPointDetailsModelProtocol
    ) {
        self.model = model
        setup()
    }

    // MARK: - Life cycle
    func setup() {
    }

    func load() {
    }
}
