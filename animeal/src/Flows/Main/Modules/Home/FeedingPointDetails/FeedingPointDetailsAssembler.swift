import UIKit
import Common

final class FeedingPointDetailsModuleAssembler {
    private let coordinator: FeedingPointCoordinatable
    private let pointId: String
    private let isOverMap: Bool

    init(coordinator: FeedingPointCoordinatable, pointId: String, isOverMap: Bool) {
        self.coordinator = coordinator
        self.pointId = pointId
        self.isOverMap = isOverMap
    }

    @MainActor
    func assemble() -> UIViewController {
        let model = FeedingPointDetailsModel(pointId: pointId)
        let viewModel = FeedingPointDetailsViewModel(
            isOverMap: isOverMap,
            model: model,
            contentMapper: FeedingPointDetailsViewMapper(),
            coordinator: coordinator
        )
        let view = FeedingPointDetailsViewController(viewModel: viewModel)
        return view
    }
}
