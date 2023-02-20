// System
import Foundation
import Combine

// SDK
import UIComponents

final class FavouritesViewModel: FavouritesViewModelLifeCycle, FavouritesViewInteraction, FavouritesViewState {
    // MARK: - Private properties
    private lazy var shimmerScheduler = ShimmerViewScheduler()

    // MARK: - Dependencies
    private let model: FavouritesModelProtocol
    private let coordinator: FavouritesCoordinatable
    private let mapper: FavouriteViewItemMappable

    // MARK: - Cancellables
    var cancellables = Set<AnyCancellable>()

    // MARK: - State
    var onErrorIsNeededToDisplay: ((String) -> Void)?
    var onContentHaveBeenPrepared: ((FavouriteViewContentState) -> Void)?
    var onMediaContentHaveBeenPrepared: ((FavouriteMediaContent) -> Void)?

    // MARK: - Initialization
    init(
        coordinator: FavouritesCoordinatable,
        mapper: FavouriteViewItemMappable = FavouriteViewItemMapper(),
        model: FavouritesModelProtocol
    ) {
        self.coordinator = coordinator
        self.mapper = mapper
        self.model = model
    }

    // MARK: - Life cycle
    func load(showLoading: Bool) {
        if showLoading {
            shimmerScheduler.start()
            updateViewItems { [weak self] in
                self?.updateViewLoadingItems() ?? []
            }
        }
        updateViewItems { [weak self] in
            guard let self else { return [] }
            self.shimmerScheduler.stop()
            return try await self.updateViewContentItems(force: showLoading)
        }
    }

    private func loadMediaContent(_ feedingPointId: String, _ key: String?) {
        guard let key = key else { return }
        model.fetchMediaContent(key: key) { [weak self] content in
            guard let self = self else { return }
            if let mediaContent = self.mapper.mapFeedingPointMediaContent(feedingPointId, content) {
                self.onMediaContentHaveBeenPrepared?(mediaContent)
            }
        }
    }

    private func updateViewLoadingItems() -> [FavouriteItem] {
        let loadingItems = (0...1).map { _ in
            FavouriteShimmerViewItem(scheduler: shimmerScheduler)
        }

        return loadingItems.map { mapper.mapShimmerViewItem($0) }
    }

    private func updateViewContentItems(force: Bool) async throws -> [FavouriteItem] {
        let favourites = try await model.fetchFavourites(force: force)
        favourites.forEach { content in
            self.loadMediaContent(content.feedingPointId, content.header.cover)
        }
        return favourites.map { self.mapper.mapFavourite($0) }
    }

    private func updateViewItems(
        _ operation: @escaping () async throws -> [FavouriteItem]
    ) {
        Task { [weak self] in
            do {
                let viewItems = try await operation()

                guard !viewItems.isEmpty else {
                    DispatchQueue.main.async { [weak self] in
                        self?.onContentHaveBeenPrepared?(.empty(L10n.Favourites.empty))
                    }
                    return
                }

                DispatchQueue.main.async { [weak self] in
                    self?.onContentHaveBeenPrepared?(.content(viewItems))
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.onErrorIsNeededToDisplay?(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: FavouritesViewActionEvent) {
        switch event {
        case .tapFeedingPoint(let pointId):
            self.coordinator.routeTo(.details(pointId))
        }
    }
}
