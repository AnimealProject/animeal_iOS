// System
import Foundation

// SDK
import Services
import Common

protocol FetchProfileItemsUseCaseLogic {
    func callAsFunction(force: Bool) async throws -> [ProfileModelItem]
    func callAsFunction(_ identifier: String) async -> ProfileModelItem?
}

protocol FetchProfileItemRequiredActionUseCase {
    typealias ProfileItemRequiredAction = PhoneModelRequiredAction

    func callAsFunction(forIdentifier identifier: String) async -> ProfileItemRequiredAction?
}

protocol UpdateProfileItemsUseCaseLogic {
    func callAsFunction(_ text: String?, forIdentifier identifier: String) async
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

    // MARK: - Private methods
    /// update state i.e. error state / Normal state for a given identifier of the profile items, this updates the items. Identity items are un touched.
    /// - Parameters:
    ///   - itemState: the state of the profile item. i.e. error / normal
    ///   - identifier: Identifer of the particular profile item which was updated.
    private func callAsFunction(_ itemState: ProfileItemState, forIdentifier identifier: String) async {
        var items = await state.items
        guard
            let itemIndex = items.firstIndex(where: { $0.identifier == identifier })
        else { return }

        var value = items[itemIndex]
        value.state = itemState
        items[itemIndex] = value

        await state.updateItems(items)
    }

    /// update type i.e. if the item is of type phone number OR email OR dirthdate, this updates the items. Identity items are un touched.
    /// - Parameters:
    ///   - type: the type of the profile item. i.e. name / surname / email / birthdate
    ///   - identifier: Identifer of the particular profile item which was updated.
    private func callAsFunction(_ type: ProfileItemType, forIdentifier identifier: String) async {
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

extension FetchProfileItemsUseCase: FetchProfileItemsUseCaseLogic {

    /// Fetch profile data from AWS Auth API, fill up the parsed data into the profile model state, also updates the items and identity items to equal.
    /// If we have any user state or profile data available. it updates it.
    /// - Parameter force: True OR False, if it is true then the API calls is done for sure. If it is flase the API call is not done.
    /// - Returns: Profile Model Item. this is the updated model.
    func callAsFunction(force: Bool) async throws -> [ProfileModelItem] {
        var isFacebook = false
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
    /// Checks the items in the state list, return the item as per identifier. No modifcation of data here.
    /// - Parameter identifier: identifier of the profile item. `ProfileModelItem`
    /// - Returns: retruns the `ProfileModelItem` from the list of items.
    func callAsFunction(_ identifier: String) async -> ProfileModelItem? {
        await state.items.first { $0.identifier == identifier }
    }
}

extension FetchProfileItemsUseCase: FetchProfileItemRequiredActionUseCase {
    /// checks for a given item having the desired identifier. Perfoms another check where if the identifier is a phone componect opens up a picker to choose region. it helps to open the picker view controller with the given model.
    /// - Parameter identifier: identifier of the profile item / component. ideally should be a phone component only.
    /// - Returns: returns an `ProfileItemRequiredAction` this is same as `PhoneModelRequiredAction` \
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
    /// update text / main value for a given identifier of the profile items, this updates the items and the changed item types. Identity items are un touched yet.
    /// - Parameters:
    ///   - text: the value of the profile item. for name is the updated name, for email it's the updated email.
    ///   - identifier: Identifer of the particular profile item which was updated.
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
}

extension FetchProfileItemsUseCase: ValidateProfileItemsUseCaseLogic {
    /// Loops through all the profile elements to validate and update state  i.e. the error state or normal state conditionally, if the update check param is true + the changed item is in the `changedItemsTypes` set, only then the state is updated. Identity items are un touched.
    /// - Parameter updateState: true of the state of the item should update. does the validaty check anyways. does not throw any error.
    /// - Returns: true if the update to all the items happenned successfully.
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
        // Check if all the items did update successfully.
        return result.allSatisfy { $0 }
    }
}
