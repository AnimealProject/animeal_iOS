import UIKit
import Common

final class FeedingBookingModuleAssembler {
    private let coordinator: FeedingBookingCoordinatable

    init(coordinator: FeedingBookingCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = FeedingBookingModel()
        let viewModel = FeedingBookingViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = FeedingBookingViewController(viewModel: viewModel)

        return view
    }
}
