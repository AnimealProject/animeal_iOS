// System
import Foundation

// SDK
import Services
import Common

final class ProfileModel: ProfileModelProtocol {
    // MARK: - Private properties
    private var items: [ProfileModelItem]
    private var actions: [ProfileModelAction]
    private var changedItemsTypes: Set<ProfileItemType>

    // MARK: - Dependencies
    private let phoneNumberProcessor: PhoneNumberRegionRecognizable
    private let profileService: UserProfileServiceProtocol

    // MARK: - Initialization
    init(
        items: [ProfileModelItem] = .editable,
        actions: [ProfileModelAction] = .completable,
        phoneNumberProcessor: PhoneNumberRegionRecognizable = PhoneNumberRegionProcessor(),
        profileService: UserProfileServiceProtocol = AppDelegate.shared.context.profileService
    ) {
        self.items = items
        self.actions = actions
        self.changedItemsTypes = .init()
        self.phoneNumberProcessor = phoneNumberProcessor
        self.profileService = profileService
    }

    // MARK: - Requests
    func fetchCachedItems() -> [ProfileModelItem] { items }

    func fetchItems() async throws -> [ProfileModelItem] {
        let userAttributes = try await profileService.fetchUserAttributes()
        let knownAttributes = userAttributes.reduce(
            [UserProfileAttributeKey: UserProfileAttribute]()
        ) { partialResult, attribute in
            var result = partialResult
            result[attribute.key] = attribute
            return result
        }
        let filledItems = items.map {
            let key = $0.type.userAttributeKey
            var item = $0
            switch item.type {
            case .phone:
                let value = knownAttributes[key]?.value ?? .empty
                if let region = phoneNumberProcessor.processRegion(value) {
                    item.type = .phone(region)
                    item.text = phoneNumberProcessor.processNumber(value)
                } else {
                    item.text = nil
                }
            default:
                item.text = knownAttributes[key]?.value
            }
            return item
        }
        self.items = filledItems
        return items
    }

    func fetchItem(_ identifier: String) -> ProfileModelItem? {
        items.first { $0.identifier == identifier }
    }

    func updateItem(_ text: String?, forIdentifier identifier: String) {
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }
        defer { changedItemsTypes.insert(items[itemIndex].type) }
        var value = items[itemIndex]
        value.text = text
        items[itemIndex] = value
    }

    func validateItems() -> Bool {
        let result = items.map { item in
            do {
                try item.validate()
                updateItem(.normal, forIdentifier: item.identifier)
                return true
            } catch let error as ProfileModelItemError {
                updateItem(.error(error.localizedDescription), forIdentifier: error.itemIdentifier)
                return false
            } catch {
                return false
            }
        }
        return result.allSatisfy { $0 }
    }

    func fetchActions() -> [ProfileModelAction] { actions }

    func fetchRequiredAction(forIdentifier identifier: String) -> PhoneModelRequiredAction? {
        guard
            let item = items.first(where: { $0.identifier == identifier })
        else { return nil }
        switch item.type {
        case .phone:
            let components: PhoneModelRequiredAction.OpenPickerComponents =
                .phoneComponents(item) { [weak self] previousRegion, updatedRegion in
                    guard updatedRegion != previousRegion else { return }
                    self?.updateItem(.phone(updatedRegion), forIdentifier: item.identifier)
                }
            return PhoneModelRequiredAction.openPicker(components)
        default:
            return nil
        }
    }

    func executeAction(_ identifier: String) -> ProfileModelIntermediateStep? {
        guard
            let action = actions.first(where: { $0.identifier == identifier }),
            let requestActions = action.action?(action.identifier)
        else { return nil }
        requestActions.forEach { requestAction in
            switch requestAction {
            case .complete:
                break
            case .changeSource(let modifier):
                let modifiedItems = modifier(items)
                items = modifiedItems
            case .changeActions(let modifier):
                let modifiedActions = modifier(actions)
                actions = modifiedActions
            }
        }
        if requestActions.contains(
            where: { if case .complete = $0 { return true }; return false }
        ) {
            return .proceed
        } else {
            return .update
        }
    }

    func proceedAction(_ identifier: String) async throws -> ProfileModelNextStep {
        let allItems = items.reduce(
            [ProfileItemType: ProfileModelItem]()
        ) { partialResult, item in
            var result = partialResult
            result[item.type] = item
            return result
        }
        let changedAttributes = try changedItemsTypes.map { type in
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

private extension ProfileModel {
    func updateItem(_ state: ProfileItemState, forIdentifier identifier: String) {
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }
        var value = items[itemIndex]
        value.state = state
        items[itemIndex] = value
    }

    func updateItem(_ type: ProfileItemType, forIdentifier identifier: String) {
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }
        var value = items[itemIndex]
        value.type = type
        items[itemIndex] = value
    }
}

extension Array where Element == ProfileModelItem {
    static var editable: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var editableExceptEmail: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var editableExceptPhone: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var readonly: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.GE), style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .readonly, state: .normal)
        ]
    }

    func toReadonly(
        except: @escaping (ProfileModelItem) -> Bool = { _ in false }
    ) -> [ProfileModelItem] {
        map { item in
            guard !except(item) else { return item }
            var item = item
            item.style = .readonly
            return item
        }
    }

    func toEditable(
        except: @escaping (ProfileModelItem) -> Bool = { _ in false }
    ) -> [ProfileModelItem] {
        map { item in
            guard !except(item) else { return item }
            var item = item
            item.style = .editable
            return item
        }
    }
}

extension ProfileItemType {
    var userAttributeKey: UserProfileAttributeKey {
        switch self {
        case .name:
            return .name
        case .surname:
            return .familyName
        case .email:
            return .email
        case .phone:
            return .phoneNumber
        case .birthday:
            return .birthDate
        }
    }

    init?(userAttributeKey: UserProfileAttributeKey) {
        switch userAttributeKey {
        case .name:
            self = .name
        case .familyName:
            self = .surname
        case .email:
            self = .email
        case .phoneNumber:
            self = .phone(.GE)
        case .birthDate:
            self = .birthday
        default:
            return nil
        }
    }
}

extension Array where Element == ProfileModelAction {
    static var editable: [ProfileModelAction] { [.edit] }

    static var completable: [ProfileModelAction] { [.done] }
}

// swiftlint: disable trailing_closure
extension ProfileModelAction {
    static var edit: ProfileModelAction {
        ProfileModelAction(
            identifier: UUID().uuidString,
            title: L10n.Profile.edit,
            isEnabled: true
        ) { _ in
            [
                .changeSource({ modelItems in return modelItems.toEditable(except: isAvailableToEdit) }),
                .changeActions({ _ in return [.save] })
            ]
        }
    }
    
    static func isAvailableToEdit(_ item: ProfileModelItem) -> Bool {
        switch item.type {
        case .name:
            return true
        case .surname:
            return true
        case .email:
            return true
        case .phone:
            return false
        case .birthday:
            return true
        }
    }

    static var save: ProfileModelAction {
        ProfileModelAction(
            identifier: UUID().uuidString,
            title: L10n.Profile.save,
            isEnabled: true
        ) { _ in
            [
                .changeSource({ modelItems in return modelItems.toReadonly() }),
                .changeActions({ _ in return [.edit] }),
                .complete
            ]
        }
    }

    static var done: ProfileModelAction {
        ProfileModelAction(
            identifier: UUID().uuidString,
            title: L10n.Profile.done,
            isEnabled: true
        ) { _ in
            [.complete]
        }
    }
}
// swiftlint: enable trailing_closure
