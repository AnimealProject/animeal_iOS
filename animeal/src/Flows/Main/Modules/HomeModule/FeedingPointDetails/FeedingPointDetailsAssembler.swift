import UIKit
import Common

final class FeedingPointDetailsModuleAssembler {
    private let coordinator: FeedingPointCoordinatable
    private let pointId: String

    init(coordinator: FeedingPointCoordinatable, pointId: String) {
        self.coordinator = coordinator
        self.pointId = pointId
    }

    func assemble() -> UIViewController {
        let model = FeedingPointDetailsModel(pointId: pointId)
        let viewModel = FeedingPointDetailsViewModel(
            model: model,
            contentMapper: FeedingPointDetailsViewMapper(),
            coordinator: coordinator
        )
        let view = FeedingPointDetailsViewController(viewModel: viewModel)
        return view
    }
}
