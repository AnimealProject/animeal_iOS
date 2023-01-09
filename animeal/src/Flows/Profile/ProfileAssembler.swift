import UIKit

@MainActor
enum ProfileAfterCustomAuthAssembler {
    static func assembly(coordinator: ProfileCoordinatable) -> UIViewController {
        let model = ProfileModel(
            items: .editableExceptPhone,
            actions: .completable
        )

        let viewModel = ProfileViewModel(
            model: model,
            coordinator: coordinator,
            mapper: ProfileViewItemMapper(),
            configuration: .afterAuth
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}

@MainActor
enum ProfileAfterSocialAuthAssembler {
    static func assembly(coordinator: ProfileCoordinatable) -> UIViewController {
        let model = ProfileModel(
            items: .editableExceptEmail,
            actions: .completable
        )

        let viewModel = ProfileViewModel(
            model: model,
            coordinator: coordinator,
            mapper: ProfileViewItemMapper(),
            configuration: .afterAuth
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}

@MainActor
enum ProfileChangeableAssembler {
    static func assembly(coordinator: ProfileCoordinatable) -> UIViewController {
        let model = ProfileModel(
            items: .readonly,
            actions: .editable
        )

        let viewModel = ProfileViewModel(
            model: model,
            coordinator: coordinator,
            mapper: ProfileViewItemMapper(),
            configuration: .fromMore
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}
