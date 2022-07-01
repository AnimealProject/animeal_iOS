import UIKit

final class ProfileModuleAssembler: Assembling {
    static func assemble() -> UIViewController {
        let model = ProfileModel()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let viewModel = ProfileViewModel(
            model: model,
            stringProcessor: PhoneNumberProcessor(),
            dateFormatter: dateFormatter
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}
