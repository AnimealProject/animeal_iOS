import Foundation
import Services

enum ProfileModelRequestAction {
    case complete
    case changeSource(([ProfileModelItem]) -> [ProfileModelItem])
    case changeActions(([ProfileModelAction]) -> [ProfileModelAction])
    case cancel
}

enum ProfileActionStyle: Equatable {
    case primary
    case secondary
}

enum ProfileModelActionUpdateTrigger: Equatable {
    case onItemsDidChange
    case onClick
}

struct ProfileModelActionAppearance {
    let identifier: String
    let title: String
    let isEnabled: Bool
    let style: ProfileActionStyle
}

protocol ProfileModelAction {
    var appearance: ProfileModelActionAppearance { get }

    func update(_ trigger: ProfileModelActionUpdateTrigger) async -> ProfileModelAction
    func execute() async throws -> ProfileModelIntermediateStep?
}

final class ProfileModelDoneAction: ProfileModelAction {
    // MARK: - Dependencies
    private let validateItems: ValidateProfileItemsUseCaseLogic

    // MARK: - Appearance
    let appearance: ProfileModelActionAppearance

    // MARK: - Initialization
    init(
        validateItems: ValidateProfileItemsUseCaseLogic,
        isEnabled: Bool = false
    ) {
        self.validateItems = validateItems
        self.appearance = .done(isEnabled: isEnabled)
    }

    // MARK: - Logic
    func update(_ trigger: ProfileModelActionUpdateTrigger) async -> ProfileModelAction {
        switch trigger {
        case .onItemsDidChange:
            if await validateItems(updateState: false) {
                return ProfileModelDoneAction(validateItems: validateItems, isEnabled: true)
            } else {
                return ProfileModelDoneAction(validateItems: validateItems, isEnabled: false)
            }
        case .onClick:
            return self
        }
    }

    func execute() async throws -> ProfileModelIntermediateStep? {
        if await validateItems(updateState: false) {
            return .proceed
        } else {
            return .none
        }
    }
}

final class ProfileModelCancelAction: ProfileModelAction {
    // MARK: - Dependencies
    private let authenticationService: AuthenticationServiceProtocol

    // MARK: - Appearance
    let appearance: ProfileModelActionAppearance

    // MARK: - Initialization
    init(authenticationService: AuthenticationServiceProtocol) {
        self.authenticationService = authenticationService
        self.appearance = .cancel
    }

    // MARK: - Logic
    func update(_ trigger: ProfileModelActionUpdateTrigger) async -> ProfileModelAction {
        self
    }

    func execute() async throws -> ProfileModelIntermediateStep? {
        .cancel({ [weak self] in try await self?.authenticationService.signOut() })
    }
}

final class ProfileModelEditAction: ProfileModelAction {
    // MARK: - Dependencies
    private let state: ProfileModelStateMutableProtocol
    private let validateItems: ValidateProfileItemsUseCaseLogic

    // MARK: - Appearance
    let appearance: ProfileModelActionAppearance

    // MARK: - Initialization
    init(state: ProfileModelStateMutableProtocol, validateItems: ValidateProfileItemsUseCaseLogic) {
        self.state = state
        self.validateItems = validateItems
        self.appearance = .edit
    }

    // MARK: - Logic
    func update(_ trigger: ProfileModelActionUpdateTrigger) async -> ProfileModelAction {
        switch trigger {
        case .onItemsDidChange:
            return self
        case .onClick:
            return ProfileModelSaveAction(
                state: state,
                validateItems: validateItems,
                isEnabled: false
            )
        }
    }

    func execute() async throws -> ProfileModelIntermediateStep? {
        let items = await state.items
        let editableItems = items.toEditable { item in
            switch item.type {
            case .name, .surname, .email, .birthday:
                return false
            case .phone:
                return true
            }
        }
        await state.updateItems(editableItems)
        return .update
    }
}

final class ProfileModelSaveAction: ProfileModelAction {
    // MARK: - Dependencies
    private let state: ProfileModelStateMutableProtocol
    private let validateItems: ValidateProfileItemsUseCaseLogic

    // MARK: - Appearance
    let appearance: ProfileModelActionAppearance

    // MARK: - Initialization
    init(
        state: ProfileModelStateMutableProtocol,
        validateItems: ValidateProfileItemsUseCaseLogic,
        isEnabled: Bool = false
    ) {
        self.state = state
        self.validateItems = validateItems
        self.appearance = .save(isEnabled: isEnabled)
    }

    // MARK: - Logic
    func update(_ trigger: ProfileModelActionUpdateTrigger) async -> ProfileModelAction {
        switch trigger {
        case .onItemsDidChange:
            let areValid = await validateItems(updateState: false)
            let isChanged = await state.isChanged
            return ProfileModelSaveAction(
                state: state,
                validateItems: validateItems,
                isEnabled: isChanged && areValid
            )
        case .onClick:
            return ProfileModelEditAction(
                state: state,
                validateItems: validateItems
            )
        }
    }

    func execute() async throws -> ProfileModelIntermediateStep? {
        let items = await state.items
        let editableItems = items.toEditable { item in
            switch item.type {
            case .name, .surname, .email, .birthday:
                return false
            case .phone:
                return true
            }
        }
        await state.updateItems(editableItems)
        return .proceed
    }
}

extension ProfileModelActionAppearance {
    static var edit: ProfileModelActionAppearance {
        ProfileModelActionAppearance(
            identifier: UUID().uuidString,
            title: L10n.Profile.edit,
            isEnabled: true,
            style: .primary
        )
    }

    static func save(isEnabled: Bool = false) -> ProfileModelActionAppearance {
        ProfileModelActionAppearance(
            identifier: UUID().uuidString,
            title: L10n.Profile.save,
            isEnabled: isEnabled,
            style: .primary
        )
    }

    static func done(isEnabled: Bool = false) -> ProfileModelActionAppearance {
        ProfileModelActionAppearance(
            identifier: UUID().uuidString,
            title: L10n.Profile.done,
            isEnabled: isEnabled,
            style: .primary
        )
    }

    static var cancel: ProfileModelActionAppearance {
        ProfileModelActionAppearance(
            identifier: UUID().uuidString,
            title: L10n.Profile.cancel,
            isEnabled: true,
            style: .secondary
        )
    }
}
