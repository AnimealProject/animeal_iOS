import UIKit
import Common

final class FeedingPointDetailsModuleAssembler {
    private let coordinator: FeedingPointCoordinatable

    init(coordinator: FeedingPointCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = FeedingPointDetailsModel()
        let viewModel = FeedingPointDetailsViewModel(
            model: model,
            contentMapper: FeedingPointDetailsViewMapper(),
            coordinator: coordinator
        )
        let view = FeedingPointDetailsViewController(viewModel: viewModel)

        viewModel.onContentHaveBeenPrepared = { [weak view] content in
            view?.applyFeedingPointContent(content)
        }

        viewModel.setup()

        return view
    }
}
