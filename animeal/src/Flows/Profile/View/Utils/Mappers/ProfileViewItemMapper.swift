// System
import UIKit

// SDK
import Common
import UIComponents
import Style

// sourcery: AutoMockable
protocol ProfileViewItemMappable {
    func mapItem(_ input: ProfileModelItem) -> ProfileViewItemProtocol
    func mapItems(_ input: [ProfileModelItem]) -> [ProfileViewItemProtocol]
}

struct ProfileViewItemMapper: ProfileViewItemMappable {
    func mapItem(_ input: ProfileModelItem) -> ProfileViewItemProtocol {
        switch input.type {
        case .phone(let region):
            guard let placeholder = region.phoneNumberPlaceholder else {
                let viewItem = ProfileTextFieldViewItem(
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
            let formatter = DefaultTextInputFormatter.phoneNumberFormatter(
                placeholder
            )
            let viewItem = ProfileTextFieldViewItem(
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
            let state: CheckBoxState = input.selected ? .checked : .unchecked
            let viewItem = ProfileAgeConsentViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                isEditable: input.isEditable,
                title: input.type.title,
                ageConsentModel: AgeConsentView.AgeConsentViewModel(state: state, title: L10n.Profile.consent)
            )
            return viewItem
        default:
            let viewItem = ProfileTextFieldViewItem(
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

    func mapItems(_ input: [ProfileModelItem]) -> [ProfileViewItemProtocol] {
        return input.map(mapItem)
    }
}
