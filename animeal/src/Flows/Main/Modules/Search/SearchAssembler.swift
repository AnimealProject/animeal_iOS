import UIKit

@MainActor
enum SearchAssembler {
    static func assembly(coordinator: SearchCoordinatable) -> UIViewController {
        let model = SearchModel()
        let viewModel = SearchViewModel(
            model: model,
            coordinator: coordinator,
            sectionMapper: SearchViewSectionMapper(
                itemMapper: SearchViewItemMapper()
            )
        )
        let view = SearchViewController(viewModel: viewModel)

        return view
    }
}
