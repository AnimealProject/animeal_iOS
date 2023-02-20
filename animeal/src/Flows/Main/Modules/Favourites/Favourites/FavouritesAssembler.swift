import Common
import UIKit

@MainActor
final class FavouritesModuleAssembler {
    // MARK: - Private properties
    private let coordinator: FavouritesCoordinatable

    // MARK: - Initialization
    init(coordinator: FavouritesCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let feedingPointsService = AppDelegate.shared.context.feedingPointsService

        let model = FavouritesModel()
        let viewModel = FavouritesViewModel(coordinator: coordinator, model: model)
        let view = FavouritesViewController(viewModel: viewModel)

        feedingPointsService.changedFeedingPoint
            .receive(on: DispatchQueue.main)
            .sink { [weak viewModel] _ in
                viewModel?.load(showLoading: false)
            }
            .store(in: &viewModel.cancellables)

        viewModel.onContentHaveBeenPrepared = { [weak view] viewState in
            view?.populateFavourites(viewState)
        }
        viewModel.onMediaContentHaveBeenPrepared = { [weak view] content in
            view?.applyFavouriteMediaContent(content)
        }

        return view
    }
}
