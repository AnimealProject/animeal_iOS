import Common
import UIKit

final class FavouritesModuleAssembler: Assembling {
    // MARK: - Private properties
    private let coordinator: FavouritesCoordinatable

    // MARK: - Initialization
    init(coordinator: FavouritesCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = FavouritesModel()
        let viewModel = FavouritesViewModel(coordinator: coordinator, model: model)
        let view = FavouritesViewController(viewModel: viewModel)

        viewModel.onContentHaveBeenPrepared = { [weak view] viewState in
            view?.populateFavourites(viewState)
        }

        viewModel.onMediaContentHaveBeenPrepared = { [weak view] content in
            view?.applyFavouriteMediaContent(content)
        }

        return view
    }
}
