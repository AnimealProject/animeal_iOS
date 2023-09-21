// System
import Foundation

// SDK
import Services
import Common

final class ProfileModel: ProfileModelProtocol {
    // MARK: - Dependencies
    private let fetchItems: FetchProfileItemsUseCaseLogic
    private let updateItems: UpdateProfileItemsUseCaseLogic
    private let validateItems: ValidateProfileItemsUseCaseLogic
    private let fetchItemRequiredAction: FetchProfileItemRequiredActionUseCase

    private let fetchActions: FetchProfileActionsUseCaseLogic
    private let discardActions: ProfileModelDiscardChangesAction
    private let executeActions: ExecuteProfileActionsUseCaseLogic

    private let updateProfile: UpdateProfileUseCaseLogic

    // MARK: - Initialization
    init(
        fetchItems: FetchProfileItemsUseCaseLogic,
        updateItems: UpdateProfileItemsUseCaseLogic,
        validateItems: ValidateProfileItemsUseCaseLogic,
        fetchItemRequiredAction: FetchProfileItemRequiredActionUseCase,
        fetchActions: FetchProfileActionsUseCaseLogic,
        discardActions: ProfileModelDiscardChangesAction,
        executeActions: ExecuteProfileActionsUseCaseLogic,
        updateProfile: UpdateProfileUseCaseLogic
    ) {
        self.fetchItems = fetchItems
        self.updateItems = updateItems
        self.validateItems = validateItems
        self.fetchItemRequiredAction = fetchItemRequiredAction
        self.fetchActions = fetchActions
        self.executeActions = executeActions
        self.updateProfile = updateProfile
        self.discardActions = discardActions
    }

    // MARK: - Requests
    func fetchCachedItems() async throws -> [ProfileModelItem] {
        try await fetchItems(force: false)
    }

    func fetchItems() async throws -> [ProfileModelItem] {
        try await fetchItems(force: true)
    }

    func fetchItem(_ identifier: String) async -> ProfileModelItem? {
        await fetchItems(identifier)
    }

    func updateItem(_ text: String?, forIdentifier identifier: String) async {
        await updateItems(text, forIdentifier: identifier)
    }

    func validateItems() async -> Bool {
        await validateItems(updateState: true)
    }

    func fetchRequiredAction(forIdentifier identifier: String) async -> PhoneModelRequiredAction? {
        await fetchItemRequiredAction(forIdentifier: identifier)
    }

    func fetchActions() async -> [ProfileModelAction] {
        await fetchActions()
    }

    func executeAction(_ identifier: String) async throws -> ProfileModelIntermediateStep? {
        try await executeActions(identifier)
    }

    func proceedAction(_ identifier: String) async throws -> ProfileModelNextStep {
        try await updateProfile(forActionIdentifier: identifier)
    }

    func discardAction() async throws -> [ProfileModelAction] {
        try await fetchActions(executeAndUpdate: [discardActions])
    }
}
