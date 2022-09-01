import UIKit
import Common

enum MorePartitionModuleAssembler {
    static func assemble(_ mode: PartitionMode) -> UIViewController {
        let model = MorePartitionModel()
        let viewModel = MorePartitionViewModel(
            model: model,
            mode: mode
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
    case help
    case about
    case account
}
