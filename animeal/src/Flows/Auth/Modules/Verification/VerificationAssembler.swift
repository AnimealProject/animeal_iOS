import UIKit

@MainActor
enum VerificationAfterCustomAuthAssembler: VerificationAssembler {
    static func assembly(
        deliveryDestination: VerificationModelDeliveryDestination
    ) -> UIViewController {
        let model = VerificationModel(
            worker: VerificationAfterCustomAuthWorker(),
            attribute: VerificationModelAttribute(
                key: VerificationModelAttributeKey.preferredUsername,
                value: deliveryDestination.value ?? .empty
            ),
            deliveryDestination: deliveryDestination
        )
        let viewModel = VerificationViewModel(
            model: model
        )
        let view = VerificationViewController(viewModel: viewModel)

        return view
    }
}
