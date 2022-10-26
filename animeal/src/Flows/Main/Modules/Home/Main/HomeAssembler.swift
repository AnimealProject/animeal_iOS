import UIKit
import Common

final class HomeModuleAssembler {
    private let coordinator: HomeCoordinatable

    init(coordinator: HomeCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = HomeModel()
        let viewModel = HomeViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = HomeViewController(viewModel: viewModel)

        viewModel.onFeedingPointsHaveBeenPrepared = { [weak view] points in
            view?.applyFeedingPoints(points)
        }

        viewModel.onSegmentsHaveBeenPrepared = { [weak view] model in
            view?.applyFilter(model)
        }

        viewModel.setup()

        return view
    }
}
