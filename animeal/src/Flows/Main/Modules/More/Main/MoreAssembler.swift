import UIKit
import Common

@MainActor
final class MoreModuleAssembler {
    private let coordinator: MoreCoordinatable
    private let userProfileService = AppDelegate.shared.context.profileService

    init(coordinator: MoreCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = MoreModel()
        let viewModel = MoreViewModel(
            coordinator: coordinator,
            model: model,
            userProfileService: userProfileService,
            authenticationService: AppDelegate.shared.context.authenticationService
        )
        let view = MoreViewController(viewModel: viewModel)

        viewModel.onActionsHaveBeenPrepared = { [weak view] actions in
            view?.applyActions(actions)
        }
        viewModel.onLogoutVisibilityHaveBeenPrepared = { [weak view] isVisible in
            view?.applyLogoutButton(isVisible: isVisible)
        }

        return view
    }
}
