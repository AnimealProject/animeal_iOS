import UIKit

enum VerificationModuleAssembler: VerificationAssembler {
    static func assembly() -> UIViewController {
        let model = VerificationModel()
        let viewModel = VerificationViewModel(
            model: model
        )
        let view = VerificationViewController(viewModel: viewModel)

        viewModel.onHeaderHasBeenPrepared = { [weak view] viewHeader in
            view?.applyHeader(viewHeader)
        }
        viewModel.onCodeHasBeenPrepared = { [weak view] viewCode, applyDiff in
            view?.applyCode(viewCode, applyDiff)
        }
        viewModel.onResendCodeHasBeenPrepared = { [weak view] viewResendCode in
            view?.applyResendCode(viewResendCode)
        }

        return view
    }
}
