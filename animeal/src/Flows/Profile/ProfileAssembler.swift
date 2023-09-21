import UIKit
import Common

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
        let modelState = ProfileModelState(items: .editableExceptPhone)
        let manipulateItems = FetchProfileItemsUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService,
            phoneNumberProcessor: PhoneNumberRegionProcessor()
        )
        let manipulateActions = FetchProfileActionsUseCase(
            actions: [
                ProfileModelCancelAction(authenticationService: AppDelegate.shared.context.authenticationService),
                ProfileModelDoneAction(validateItems: manipulateItems, isEnabled: false)
            ]
        )
        let discardChanges = ProfileModelDiscardChangesAction(state: modelState, validateItems: manipulateItems)
        let updateProfile = UpdateProfileUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService
        )
        let model = ProfileModel(
            fetchItems: manipulateItems,
            updateItems: manipulateItems,
            validateItems: manipulateItems,
            fetchItemRequiredAction: manipulateItems,
            fetchActions: manipulateActions,
            discardActions: discardChanges,
            executeActions: manipulateActions,
            updateProfile: updateProfile
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
        let modelState = ProfileModelState(items: .editableExceptEmail)
        let manipulateItems = FetchProfileItemsUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService,
            phoneNumberProcessor: PhoneNumberRegionProcessor()
        )
        let manipulateActions = FetchProfileActionsUseCase(
            actions: [
                ProfileModelCancelAction(authenticationService: AppDelegate.shared.context.authenticationService),
                ProfileModelDoneAction(validateItems: manipulateItems, isEnabled: false)
            ]
        )
        let discardChanges = ProfileModelDiscardChangesAction(state: modelState, validateItems: manipulateItems)
        let updateProfile = UpdateProfileUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService
        )
        let model = ProfileModel(
            fetchItems: manipulateItems,
            updateItems: manipulateItems,
            validateItems: manipulateItems,
            fetchItemRequiredAction: manipulateItems,
            fetchActions: manipulateActions,
            discardActions: discardChanges,
            executeActions: manipulateActions,
            updateProfile: updateProfile
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
        let modelState = ProfileModelState(items: .readonly)
        let manipulateItems = FetchProfileItemsUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService,
            phoneNumberProcessor: PhoneNumberRegionProcessor()
        )
        let manipulateActions = FetchProfileActionsUseCase(
            actions: [
                ProfileModelEditAction(state: modelState, validateItems: manipulateItems)
            ]
        )
        let discardChanges = ProfileModelDiscardChangesAction(state: modelState, validateItems: manipulateItems)
        let updateProfile = UpdateProfileUseCase(
            state: modelState,
            profileService: AppDelegate.shared.context.profileService
        )
        let model = ProfileModel(
            fetchItems: manipulateItems,
            updateItems: manipulateItems,
            validateItems: manipulateItems,
            fetchItemRequiredAction: manipulateItems,
            fetchActions: manipulateActions,
            discardActions: discardChanges,
            executeActions: manipulateActions,
            updateProfile: updateProfile
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
