// System
import Foundation

// SDK
import Services
import Common

protocol FetchProfileItemsUseCaseLogic {
    func callAsFunction(force: Bool) async throws -> [ProfileModelItem]
    func callAsFunction(_ identifier: String) async -> ProfileModelItem?
}

protocol FetchProfileItemRequiredActionUseCaseLogic {
    typealias ProfileItemRequiredAction = PhoneModelRequiredAction

    func callAsFunction(forIdentifier identifier: String) async -> ProfileItemRequiredAction?
}

protocol UpdateProfileItemsUseCaseLogic {
    func callAsFunction(_ text: String?, forIdentifier identifier: String) async
    func callAsFunction(_ state: ProfileItemState, forIdentifier identifier: String) async
    func callAsFunction(_ type: ProfileItemType, forIdentifier identifier: String) async
}

protocol ValidateProfileItemsUseCaseLogic {
    func callAsFunction(updateState: Bool) async -> Bool
}

final class FetchProfileItemsUseCase {
    private let state: ProfileModelStateMutableProtocol
    private let profileService: UserProfileServiceProtocol
    private let phoneNumberProcessor: PhoneNumberRegionRecognizable
    private let dateFormatter = DateFormatter()
    
    init(
        state: ProfileModelStateMutableProtocol,
        profileService: UserProfileServiceProtocol,
        phoneNumberProcessor: PhoneNumberRegionRecognizable
    ) {
        self.state = state
        self.profileService = profileService
        self.phoneNumberProcessor = phoneNumberProcessor
    }
}

extension FetchProfileItemsUseCase: FetchProfileItemsUseCaseLogic {
    func callAsFunction(force: Bool) async throws -> [ProfileModelItem] {
        var isFacebook: Bool = false
        let items = await state.items
        guard force else { return items }
        let userAttributes = try await profileService.fetchUserAttributes()
        let knownAttributes = userAttributes.reduce(
            [UserProfileAttributeKey: UserProfileAttribute]()
        ) { partialResult, attribute in
            var result = partialResult
            result[attribute.key] = attribute
            return result
        }

        userAttributes.forEach { attribute in
            if (attribute.key == .unknown("identities")) && attribute.value.contains("Facebook") {
                isFacebook = true
            }
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
            case .birthday where isFacebook:
                dateFormatter.dateFormat = "MM/dd/yyyy"
                if let birthDate = knownAttributes[key]?.value,
                   let date = dateFormatter.date(from: birthDate) {
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        item.text = dateFormatter.string(from: date)
                }
            default:
                item.text = knownAttributes[key]?.value
            }
            return item
        }
        await state.updateIdentityItems(filledItems)
        await state.updateItems(filledItems)
        return filledItems
    }

    func callAsFunction(_ identifier: String) async -> ProfileModelItem? {
        await state.items.first { $0.identifier == identifier }
    }
}

extension FetchProfileItemsUseCase: FetchProfileItemRequiredActionUseCaseLogic {
    func callAsFunction(forIdentifier identifier: String) async -> ProfileItemRequiredAction? {
        let items = await state.items
        guard
            let item = items.first(where: { $0.identifier == identifier })
        else { return nil }
        switch item.type {
        case .phone:
            let components: PhoneModelRequiredAction.OpenPickerComponents =
                .phoneComponents(item) { [weak self] previousRegion, updatedRegion in
                    guard updatedRegion != previousRegion else { return }
                    await self?.callAsFunction(.phone(updatedRegion), forIdentifier: item.identifier)
                }
            return PhoneModelRequiredAction.openPicker(components)
        default:
            return nil
        }
    }
}

extension FetchProfileItemsUseCase: UpdateProfileItemsUseCaseLogic {
    func callAsFunction(_ text: String?, forIdentifier identifier: String) async {
        var items = await state.items
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }

        var value = items[itemIndex]
        value.text = text
        items[itemIndex] = value

        var changedItemsTypes = await state.changedItemsTypes
        changedItemsTypes.insert(items[itemIndex].type)

        await state.updateItems(items)
        await state.updateChangedItemsTypes(changedItemsTypes)
    }

    func callAsFunction(_ itemState: ProfileItemState, forIdentifier identifier: String) async {
        var items = await state.items
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }

        var value = items[itemIndex]
        value.state = itemState
        items[itemIndex] = value

        await state.updateItems(items)
    }

    func callAsFunction(_ type: ProfileItemType, forIdentifier identifier: String) async {
        var items = await state.items
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }

        var value = items[itemIndex]
        value.type = type
        items[itemIndex] = value

        await state.updateItems(items)
    }
}

extension FetchProfileItemsUseCase: ValidateProfileItemsUseCaseLogic {
    func callAsFunction(updateState: Bool) async -> Bool {
        let items = await state.items

        let result = await items.asyncMap { item in
            do {
                try item.validate()
                if updateState {
                    await callAsFunction(.normal, forIdentifier: item.identifier)
                }
                return true
            } catch let error as ProfileModelItemError {
                if updateState, await state.changedItemsTypes.contains(item.type) {
                    await callAsFunction(
                        .error(error.localizedDescription),
                        forIdentifier: error.itemIdentifier
                    )
                }
                return false
            } catch {
                return false
            }
        }

        return result.allSatisfy { $0 }
    }
}
