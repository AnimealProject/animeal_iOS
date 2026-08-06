import UIKit
import Common

final class FeedingFinishedModuleAssembler {

    private let coordinator: FeedingFinishedCoordinatable

    init(coordinator: FeedingFinishedCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble(isTrusted: Bool) -> UIViewController {
        let model = FeedingFinishedModel(isTrusted: isTrusted)
        let viewModel = FeedingFinishedViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = FeedingFinishedViewController(viewModel: viewModel)

        return view
    }
}
