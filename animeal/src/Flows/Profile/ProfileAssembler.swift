import UIKit

@MainActor
enum ProfileAfterUnknownAuthAssembler {
    static func assembly(coordinator: ProfileCoordinatable) -> UIViewController {
        let context: AppContext = AppDelegate.shared.context
        let defaultsService = context.defaultsService
        
        guard
            let authTypeValue: String = defaultsService.value(key: LoginActionType.storableKey),
            let authType = LoginActionType(rawValue: authTypeValue)
        else {
            return ProfileAfterSocialAuthAssembler.assembly(coordinator: coordinator)
        }
        
        switch authType {
        case .signInViaPhoneNumber:
            return ProfileAfterCustomAuthAssembler.assembly(coordinator: coordinator)
        case .signInViaAppleID, .signInViaFacebook:
            return ProfileAfterSocialAuthAssembler.assembly(coordinator: coordinator)
        }
    }
}

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
