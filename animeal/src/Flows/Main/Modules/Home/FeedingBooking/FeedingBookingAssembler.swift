import UIKit
import Common

final class FeedingBookingModuleAssembler {
    private let coordinator: FeedingBookingCoordinatable
    private let feedingDetails: FeedingPointFeedDetails

    init(coordinator: FeedingBookingCoordinatable, feedingDetails: FeedingPointFeedDetails) {
        self.coordinator = coordinator
        self.feedingDetails = feedingDetails
    }

    func assemble() -> UIViewController {
        let model = FeedingBookingModel()
        let viewModel = FeedingBookingViewModel(
            model: model,
            coordinator: coordinator,
            feedingDetails: feedingDetails
        )
        let view = FeedingBookingViewController(viewModel: viewModel)

        return view
    }
}
