import UIKit
import Common

@MainActor
enum DonateModuleAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {
        let model = DonateModel()
        let viewModel = DonateViewModel(
            model: model,
            coordinator: coordinator
        )

        let view = DonateViewController(viewModel: viewModel)

        return view
    }
}
