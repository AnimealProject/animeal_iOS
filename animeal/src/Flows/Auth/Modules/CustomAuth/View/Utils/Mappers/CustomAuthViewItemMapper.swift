// System
import Foundation

// SDK
import Common
import UIComponents
import UIKit

// sourcery: AutoMockable
protocol CustomAuthViewItemMappable {
    func mapItem(_ input: CustomAuthModelItem) -> CustomAuthViewItem
    func mapItems(_ input: [CustomAuthModelItem]) -> [CustomAuthViewItem]
}

struct CustomAuthViewItemMapper: CustomAuthViewItemMappable {
    func mapItem(_ input: CustomAuthModelItem) -> CustomAuthViewItem {
        switch input.type {
        case .phone(let region):
            guard let placeholder = region.phoneNumberPlaceholder else {
                let viewItem = CustomAuthViewItem(
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
                        text: input.text
                    )
                )
                return viewItem
            }
            let formatter = DefaultTextInputFormatter.phoneNumberFormatter(
                placeholder
            )
            let viewItem = CustomAuthViewItem(
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
                    text: formatter.format(input.text)
                )
            )
            return viewItem
        case .password:
            let viewItem = CustomAuthViewItem(
                identifier: input.identifier,
                type: input.type,
                state: input.state,
                formatter: nil,
                isEditable: input.isEditable,
                title: input.type.title,
                content: DefaultTextContentView.Model(
                    placeholder: "********",
                    text: input.text,
                    isSecure: true
                )
            )
            return viewItem
        }
    }

    func mapItems(_ input: [CustomAuthModelItem]) -> [CustomAuthViewItem] {
        return input.map(mapItem)
    }
}

extension DefaultTextInputFormatter {
    static func phoneNumberFormatter(_ format: String) -> DefaultTextInputFormatter {
        DefaultTextInputFormatter(textPattern: format)
    }
}

extension Region {
    var phoneNumberPlaceholder: String? {
        switch self {
        case .GE:
            return "xxx xx-xx-xx"
        default:
            guard let digitsCount = phoneNumberDigitsCount.max()
            else { return nil }
            return (0..<digitsCount)
                .reduce("", { partialResult, _ in partialResult + "x" })
        }
    }

    var flag: UIImage? {
        UIImage(named: rawValue.lowercased())
    }
}
