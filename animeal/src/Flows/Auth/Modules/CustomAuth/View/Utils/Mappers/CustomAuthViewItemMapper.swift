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
            let formatter = PlaceholderTextInputFormatter.phoneNumberFormatter(
                region.phoneNumberPlaceholder
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
                    placeholder: region.phoneNumberPlaceholder,
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

extension PlaceholderTextInputFormatter {
    static func phoneNumberFormatter(_ format: String) -> PlaceholderTextInputFormatter {
        PlaceholderTextInputFormatter(textPattern: format)
    }
}

extension Region {
    var phoneNumberPlaceholder: String {
        switch self {
        case .GE:
            return "xxx xx-xx-xx"
        }
    }

    var flag: UIImage? {
        switch self {
        case .GE:
            return UIImage(named: "flag_georgia")
        }
    }
}
