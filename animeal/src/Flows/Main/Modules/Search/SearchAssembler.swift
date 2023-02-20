import UIKit

@MainActor
enum SearchAssembler {
    static func assembly(coordinator: SearchCoordinatable) -> UIViewController {
        let feedingPointsService = AppDelegate.shared.context.feedingPointsService

        let model = SearchModel()
        let viewModel = SearchViewModel(
            model: model,
            coordinator: coordinator,
            sectionMapper: SearchViewSectionMapper(
                itemMapper: SearchViewItemMapper()
            )
        )
        let view = SearchViewController(viewModel: viewModel)

        feedingPointsService.changedFeedingPoint
            .receive(on: DispatchQueue.main)
            .sink { [weak viewModel] _ in
                viewModel?.load(showLoading: false)
            }
            .store(in: &viewModel.cancellables)

        return view
    }
}
