import UIKit
import Common

final class HomeModuleAssembler: Assembling {
    static func assemble() -> UIViewController {
        let model = HomeModel()
        let viewModel = HomeViewModel(
            model: model
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
