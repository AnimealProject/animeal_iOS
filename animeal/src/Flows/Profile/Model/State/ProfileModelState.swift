import Foundation

protocol ProfileModelStateProtocol {
    var items: [ProfileModelItem] { get async }
    var changedItemsTypes: Set<ProfileItemType> { get async }
    var isChanged: Bool { get async }
}

protocol ProfileModelStateMutableProtocol: ProfileModelStateProtocol {
    func updateItems(_ items: [ProfileModelItem]) async
    func updateIdentityItems(_ items: [ProfileModelItem]) async
    func updateChangedItemsTypes(_ types: Set<ProfileItemType>) async
    func resetIndentityItems() async
}

actor ProfileModelState: ProfileModelStateMutableProtocol {
    private(set) var items: [ProfileModelItem]
    private(set) var identityItems: [ProfileModelItem]
    private(set) var changedItemsTypes: Set<ProfileItemType>
    private(set) var isChanged: Bool

    init(items: [ProfileModelItem], changedItemsTypes: Set<ProfileItemType> = .init()) {
        self.items = items
        self.identityItems = items
        self.changedItemsTypes = changedItemsTypes
        self.isChanged = changedItemsTypes.isEmpty
    }

    func updateItems(_ items: [ProfileModelItem]) {
        self.items = items
        self.isChanged = !identityItems.elementsEqual(items) { lhsItem, rhsItem in
            lhsItem.isEqual(to: rhsItem, ignoreStyle: true)
        }
    }

    func updateIdentityItems(_ items: [ProfileModelItem]) async {
        self.identityItems = items
    }

    func updateChangedItemsTypes(_ types: Set<ProfileItemType>) {
        self.changedItemsTypes = types
    }

    func resetIndentityItems() {
        self.items = self.identityItems
        self.changedItemsTypes = .init()
    }
}

private extension ProfileModelItem {
    func isEqual(to another: ProfileModelItem, ignoreStyle: Bool = true) -> Bool {
        guard ignoreStyle else {
            return self == another
        }
        return identifier == another.identifier &&
            type == another.type &&
            state == another.state &&
            text == another.text
    }
}
