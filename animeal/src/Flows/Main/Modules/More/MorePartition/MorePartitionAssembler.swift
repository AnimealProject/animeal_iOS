import UIKit
import Common

@MainActor
final class MorePartitionModuleAssembler {
    private let coordinator: MorePartitionCoordinatable

    init(coordinator: MorePartitionCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble(_ mode: PartitionMode) -> UIViewController {
        let model = MorePartitionModel(AppDelegate.shared.context)
        let viewModel = MorePartitionViewModel(
            model: model,
            mode: mode,
            coordinator: coordinator
        )
        let view = MorePartitionViewController(viewModel: viewModel)

        viewModel.onContentHaveBeenPrepared = { [weak view] content in
            view?.applyContentModel(content)
        }

        return view
    }
}

enum PartitionMode {
    case donate
    case faq
    case about
    case account
}
