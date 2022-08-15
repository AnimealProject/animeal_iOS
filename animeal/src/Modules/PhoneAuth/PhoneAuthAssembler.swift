// System
import UIKit

// SDK
import Common

enum PhoneAuthAssembler {
    static func assembly(coordinator: PhoneAuthCoordinatable) -> UIViewController {
        let model = PhoneAuthModel(
            authenticationService: AppDelegate.shared.context.authenticationService
        )
        let viewModel = PhoneAuthViewModel(
            model: model,
            coordinator: coordinator,
            mapper: PhoneAuthViewItemMapper()
        )
        let view = PhoneAuthViewController(viewModel: viewModel)

        viewModel.setup()

        return view
    }
}
