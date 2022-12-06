import UIKit
import Common

final class HomeModuleAssembler {
    private let coordinator: HomeCoordinatable & HomeCoordinatorEventHandlerProtocol

    init(coordinator: HomeCoordinatable & HomeCoordinatorEventHandlerProtocol ) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = HomeModel()
        let viewModel = HomeViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = HomeViewController(viewModel: viewModel)

        viewModel.setup()

        return view
    }
}
