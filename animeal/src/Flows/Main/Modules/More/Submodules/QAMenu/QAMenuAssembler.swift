import UIKit
import Common

@MainActor
enum QAMenuModuleAssembler {
    static func assemble(coordinator: MorePartitionCoordinatable) -> UIViewController {
        let model = QAMenuModel(backendEnvironments: BackendEnvironment.allCases)
        let viewModel = QAMenuViewModel(
            model: model,
            coordinator: coordinator
        )
        let view = QAMenuViewController(viewModel: viewModel)

        return view
    }
}
