import UIKit

@MainActor
enum VerificationAfterCustomAuthAssembler {
    static func assembly(
        coordinator: VerificationCoordinatable,
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
            model: model,
            coordinator: coordinator
        )
        let view = VerificationViewController(viewModel: viewModel)

        return view
    }
}
