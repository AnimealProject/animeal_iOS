import UIKit
import Common

final class MoreModuleAssembler {
    private let coordinator: MoreCoordinatable
    private let userProfileService = AppDelegate.shared.context.profileService

    init(coordinator: MoreCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = MoreModel()
        let viewModel = MoreViewModel(coordinator: coordinator, model: model, userProfileService: userProfileService)
        let view = MoreViewController(viewModel: viewModel)

        viewModel.onActionsHaveBeenPrepared = { [weak view] actions in
            view?.applyActions(actions)
        }

        return view
    }
}
