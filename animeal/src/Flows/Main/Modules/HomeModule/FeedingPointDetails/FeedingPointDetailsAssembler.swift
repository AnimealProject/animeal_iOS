import UIKit
import Common

final class FeedingPointDetailsModuleAssembler: Assembling {
    static func assemble() -> UIViewController {
        let model = FeedingPointDetailsModel()
        let viewModel = FeedingPointDetailsViewModel(
            model: model
        )
        let view = FeedingPointDetailsViewController(viewModel: viewModel)

        return view
    }
}
