import Foundation

// MARK: - View
@MainActor
protocol FavouritesViewModelOutput: AnyObject {
    func populateFavourites(_ viewState: FavouriteViewContentState)
    func applyFavouriteMediaContent(_ content: FavouriteMediaContent)
}

// MARK: - Model
protocol FavouritesModelProtocol: AnyObject {
    func fetchFavourites(force: Bool) async throws -> [FavouritesModel.FavouriteContent]
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?)
}

// MARK: - ViewModel
typealias FavouritesCombinedViewModel = FavouritesViewModelLifeCycle &
                                        FavouritesViewInteraction &
                                        FavouritesViewState

@MainActor
protocol FavouritesViewModelLifeCycle: AnyObject {
    func load(showLoading: Bool)
}

extension FavouritesViewModelLifeCycle {
    func load() {
        load(showLoading: true)
    }
}

@MainActor
protocol FavouritesViewInteraction: AnyObject {
    func handleActionEvent(_ event: FavouritesViewActionEvent)
}

@MainActor
protocol FavouritesViewState: AnyObject { }

enum FavouritesViewActionEvent {
    case tapFeedingPoint(String)
}

// MARK: - Coordinator
protocol FavouritesCoordinatable {
    func routeTo(_ route: FavouritesRoute)
}

enum FavouritesRoute {
    case details(String)
}
