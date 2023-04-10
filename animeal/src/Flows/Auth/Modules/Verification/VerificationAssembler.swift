import UIKit

@MainActor
enum VerificationAfterCustomAuthAssembler {
    static func assembly(
        coordinator: VerificationCoordinatable,
        deliveryDestination: VerificationModelDeliveryDestination,
        completion: (() -> Void)?
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
            coordinator: coordinator,
            completion: completion
        )
        let view = VerificationViewController(viewModel: viewModel)

        return view
    }
}

@MainActor
enum VerificationAfterProfileAuthAssembler {
    static func assembly(
        coordinator: VerificationCoordinatable,
        deliveryDestination: VerificationModelDeliveryDestination,
        attribute: VerificationModelAttribute,
        completion: (() -> Void)?
    ) -> UIViewController {
        let model = VerificationModel(
            worker: VerificationAfterChangingUserAttributeWorker(
                userProfileService: AppDelegate.shared.context.profileService
            ),
            attribute: attribute,
            deliveryDestination: deliveryDestination
        )
        let viewModel = VerificationViewModel(
            model: model,
            coordinator: coordinator,
            completion: completion
        )
        let view = VerificationViewController(viewModel: viewModel)

        return view
    }
}
