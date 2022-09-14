// System
import UIKit

// SDK
import Common

@MainActor
enum CustomAuthAssembler {
    static func assembly(coordinator: CustomAuthCoordinatable) -> UIViewController {
        let model = CustomAuthModel()
        let viewModel = CustomAuthViewModel(
            model: model,
            coordinator: coordinator,
            mapper: CustomAuthViewItemMapper()
        )
        let view = CustomAuthViewController(viewModel: viewModel)

        viewModel.setup()

        return view
    }
}
