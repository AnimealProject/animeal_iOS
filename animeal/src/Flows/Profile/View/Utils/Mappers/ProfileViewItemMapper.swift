// System
import UIKit

// SDK
import Common
import UIComponents
import Style

// sourcery: AutoMockable
protocol ProfileViewItemMappable {
    func mapItem(_ input: ProfileModelItem) -> ProfileViewItem
    func mapItems(_ input: [ProfileModelItem]) -> [ProfileViewItem]
}

struct ProfileViewItemMapper: ProfileViewItemMappable {
    func mapItem(_ input: ProfileModelItem) -> ProfileViewItem {
        switch input.type {
        case .phone(let region):
            guard let placeholder = region.phoneNumberPlaceholder else {
                let viewItem = ProfileViewItem(
                    identifier: input.identifier,
                    type: input.type,
                    state: input.state,
                    formatter: nil,
                    isEditable: input.isEditable,
                    title: input.type.title,
                    content: PhoneTextContentView.Model(
                        icon: region.flag,
                        prefix: region.phoneNumberCode,
                        placeholder: .empty,
                        text: input.text,
                        isEditable: input.isEditable
                    )
                )
                return viewItem
            }
            let formatter = PlaceholderTextInputFormatter.phoneNumberFormatter(
                placeholder
            )
            let viewItem = ProfileViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                formatter: formatter,
                isEditable: input.isEditable,
                title: input.type.title,
                content: PhoneTextContentView.Model(
                    icon: region.flag,
                    prefix: region.phoneNumberCode,
                    placeholder: placeholder,
                    text: formatter.format(input.text),
                    isEditable: input.isEditable
                )
            )
            return viewItem
        case .birthday:
            let viewItem = ProfileViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                formatter: nil,
                isEditable: input.isEditable,
                title: input.type.title,
                content: DateTextContentView.Model(
                    placeholder: input.type.title,
                    text: input.text,
                    isEditable: input.isEditable,
                    rightActions: [
                        .init(
                            identifier: UUID().uuidString,
                            icon: Asset.Images.calendar.image,
                            action: nil
                        )
                    ]
                )
            )
            return viewItem
        default:
            let viewItem = ProfileViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                formatter: nil,
                isEditable: input.isEditable,
                title: input.type.title,
                content: DefaultTextContentView.Model(
                    placeholder: input.type.title,
                    text: input.text,
                    isEditable: input.isEditable
                )
            )
            return viewItem
        }
    }

    func mapItems(_ input: [ProfileModelItem]) -> [ProfileViewItem] {
        return input.map(mapItem)
    }
}
