import UIKit
import Common

final class FeedingFinishedModuleAssembler {

    private let coordinator: FeedingFinishedCoordinatable

    init(coordinator: FeedingFinishedCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = FeedingFinishedModel()
        let viewModel = FeedingFinishedViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = FeedingFinishedViewController(viewModel: viewModel)

        return view
    }
}
