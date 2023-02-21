import UIKit
import Common

final class FAQModuleAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {
        let model = FAQModel()
        let viewModel = FAQViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = FAQViewController(viewModel: viewModel)

        return view
    }
}
