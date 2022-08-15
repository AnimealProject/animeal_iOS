import Foundation

// sourcery: AutoMockable
protocol PhoneAuthViewItemMappable {
    func mapItem(_ input: PhoneAuthModelItem) -> PhoneAuthViewItem
    func mapItems(_ input: [PhoneAuthModelItem]) -> [PhoneAuthViewItem]
}

struct PhoneAuthViewItemMapper: PhoneAuthViewItemMappable {
    func mapItem(_ input: PhoneAuthModelItem) -> PhoneAuthViewItem {
        switch input.type {
        case .phone:
            let viewItem = PhoneAuthViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                isEditable: input.isEditable,
                title: input.type.title,
                placeholder: "xxx xx-xx-xx",
                text: input.text
            )
            return viewItem
        case .password:
            let viewItem = PhoneAuthViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                isEditable: input.isEditable,
                title: input.type.title,
                placeholder: "************",
                text: input.text
            )
            return viewItem
        }
    }

    func mapItems(_ input: [PhoneAuthModelItem]) -> [PhoneAuthViewItem] {
        return input.map(mapItem)
    }
}
