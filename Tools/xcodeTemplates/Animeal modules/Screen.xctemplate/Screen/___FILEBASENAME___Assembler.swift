import UIKit
import Common

final class ___VARIABLE_productName:identifier___ModuleAssembler {
    static func assemble() -> UIViewController {
        let model = ___VARIABLE_productName:identifier___Model()
        let viewModel = ___VARIABLE_productName:identifier___ViewModel(
            model: model
        )
        let view = ___VARIABLE_productName:identifier___ViewController(viewModel: viewModel)

        return view
    }
}
