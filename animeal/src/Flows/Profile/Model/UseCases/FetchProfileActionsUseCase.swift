import Foundation
import Services

protocol FetchProfileActionsUseCaseLogic {
    func callAsFunction() async -> [ProfileModelAction]
    func callAsFunction(executeAndUpdate actions: [ProfileModelAction]) async throws -> [ProfileModelAction]
}

protocol ExecuteProfileActionsUseCaseLogic {
    func callAsFunction(_ identifier: String) async throws -> ProfileModelIntermediateStep?
}

final class FetchProfileActionsUseCase: FetchProfileActionsUseCaseLogic {
    private var actions: [ProfileModelAction]

    init(actions: [ProfileModelAction]) {
        self.actions = actions
    }

    /// Triggers `onItemsDidChange` event on the list of all of actions and replaces the list of actions with the ones returned by update trigger method.
    /// - Returns: the list of updated actions post the trigger event.
    func callAsFunction() async -> [ProfileModelAction] {
        actions = await actions.asyncMap { await $0.update(.onItemsDidChange) }
        return actions
    }
}

extension FetchProfileActionsUseCase: ExecuteProfileActionsUseCaseLogic {

    /// Triggers the 'onClick' events for all the profile actions in addition to the execute event.
    /// - Parameter identifier: identifier of the action
    /// - Returns: any intermediate step post 'execution' of the action. Check the given execute method of the action.
    func callAsFunction(_ identifier: String) async throws -> ProfileModelIntermediateStep? {
        guard
            let actionIndex = actions.firstIndex(where: { $0.appearance.identifier == identifier })
        else { return nil }

        let activeAction = actions[actionIndex]
        let updatedActon = await activeAction.update(.onClick)
        actions[actionIndex] = updatedActon

        let step = try await activeAction.execute()

        return step
    }

    func callAsFunction(executeAndUpdate actions: [ProfileModelAction]) async throws -> [ProfileModelAction] {
        self.actions = try await actions.asyncMap {
            try await $0.execute()
            return await $0.update(.onClick)
        }
        return self.actions
    }
}

protocol UpdateProfileUseCaseLogic {
    func callAsFunction(forActionIdentifier identifier: String) async throws -> ProfileModelNextStep
}

/// API call to update the user profile
final class UpdateProfileUseCase: UpdateProfileUseCaseLogic {
    private let state: ProfileModelStateProtocol
    private let profileService: UserProfileServiceProtocol

    init(state: ProfileModelStateProtocol, profileService: UserProfileServiceProtocol) {
        self.state = state
        self.profileService = profileService
    }
    /// Parse the current model into a form acceptable to the API calling entity. i.e. AWS auth SDK.
    /// - Parameter identifier: identifier of the action
    /// - Returns: next step for the action. in this case confirm or done.
    func callAsFunction(forActionIdentifier identifier: String) async throws -> ProfileModelNextStep {
        let allItems = await state.items.reduce(
            [ProfileItemType: ProfileModelItem]()
        ) { partialResult, item in
            var result = partialResult
            result[item.type] = item
            return result
        }
        let changedAttributes = try await state.changedItemsTypes.map { type in
            let item = allItems[type]
            return UserProfileAttribute(
                type.userAttributeKey,
                value: try item?.validate() ?? .empty
            )
        }
        let result = try await profileService.update(userAttributes: changedAttributes)
        var resendMethod = ResendMethod.resendCode
        if let phoneUpdateResult = result[.phoneNumber],
           !phoneUpdateResult.isUpdated,
           let phoneNumber = changedAttributes.first(where: { $0.key == .phoneNumber })?.value {
            resendMethod = .updateAttribute(phoneNumber)
        }
        if let step = result.first(
            where: { if case .confirmAttributeWithCode = $0.value.nextStep { return true }; return false }
        ), case .confirmAttributeWithCode(let details, _) = step.value.nextStep {
            return .confirm(
                details,
                UserProfileAttribute(
                    step.key,
                    value: allItems.first(
                        where: { $0.key.userAttributeKey == step.key }
                    )?.value.text ?? .empty
                ),
                resendMethod
            )
        } else {
            return .done
        }
    }
}
