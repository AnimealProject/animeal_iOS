import UIKit
import Common

@MainActor
enum AboutModuleAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {
        let model = AboutModel()
        let viewModel = AboutViewModel(
            model: model,
            coordinator: coordinator,
            linkOpener: DefaultLinkOpener()
        )
        let view = AboutViewController(viewModel: viewModel)

        return view
    }
}
