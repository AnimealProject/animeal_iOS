import Foundation
import Services

protocol FetchProfileActionsUseCaseLogic {
    func callAsFunction() async -> [ProfileModelAction]
}

protocol ExecuteProfileActionsUseCaseLogic {
    func callAsFunction(_ identifier: String) async throws -> ProfileModelIntermediateStep?
}

final class FetchProfileActionsUseCase: FetchProfileActionsUseCaseLogic {
    private var actions: [ProfileModelAction]

    init(actions: [ProfileModelAction]) {
        self.actions = actions
    }

    func callAsFunction() async -> [ProfileModelAction] {
        actions = await actions.asyncMap { await $0.update(.onItemsDidChange) }
        return actions
    }
}

extension FetchProfileActionsUseCase: ExecuteProfileActionsUseCaseLogic {
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
}

protocol UpdateProfileUseCaseLogic {
    func callAsFunction(forActionIdentifier identifier: String) async throws -> ProfileModelNextStep
}

final class UpdateProfileUseCase: UpdateProfileUseCaseLogic {
    private let state: ProfileModelStateProtocol
    private let profileService: UserProfileServiceProtocol

    init(state: ProfileModelStateProtocol, profileService: UserProfileServiceProtocol) {
        self.state = state
        self.profileService = profileService
    }

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
        if let step = result.first(
            where: { if case .confirmAttributeWithCode = $0.value.nextStep { return true }; return false }
        ), case .confirmAttributeWithCode(let details, _) = step.value.nextStep {
            return .confirm(
                details,
                UserProfileAttribute(
                    step.key,
                    value: allItems.first(
                        where: { $0.key.userAttributeKey == step.key}
                    )?.value.text ?? .empty
                )
            )
        } else {
            return .done
        }
    }
}
