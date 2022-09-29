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
            mapper: ProfileViewItemMapper()
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}

@MainActor
enum ProfileAfterSocialAuthAssembler {
    static func assembly(coordinator: ProfileCoordinatable) -> UIViewController {
        let model = ProfileModel(
            items: .editable,
            actions: .completable
        )

        let viewModel = ProfileViewModel(
            model: model,
            coordinator: coordinator,
            mapper: ProfileViewItemMapper()
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
            mapper: ProfileViewItemMapper()
        )
        let view = ProfileViewController(viewModel: viewModel)

        return view
    }
}
