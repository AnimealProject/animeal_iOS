import Foundation
import Common
import Services

enum CustomAuthItemType: Hashable {
    case phone(Region)
    case password

    var title: String {
        switch self {
        case .phone:
            return L10n.Phone.Fields.phoneTitlle
        case .password:
            return L10n.Phone.Fields.passwordTitlle
        }
    }
}

enum CustomAuthItemStyle: Hashable {
    case editable
}

enum CustomAuthItemState: Hashable {
    case normal
    case error(String)
}

protocol CustomAuthModelValidatable {
    func validate() throws -> String
}

struct CustomAuthModelItem: CustomAuthModelValidatable {
    let identifier: String
    let type: CustomAuthItemType
    let style: CustomAuthItemStyle
    var state: CustomAuthItemState
    var text: String?

    func validate() throws -> String {
        switch type {
        case .phone(let region):
            return try validatePhone(region)
        case .password:
            return try validatePassword()
        }
    }
}

extension CustomAuthModelItem {
    var isEditable: Bool {
        switch style {
        case .editable:
            return true
        }
    }

    func validatePhone(_ region: Region) throws -> String {
        guard let text = text else {
            throw CustomAuthModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Phone.Errors.empty
            )
        }

        guard text.count == region.phoneNumberDigitsCount else {
            throw CustomAuthModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Phone.Errors.empty
            )
        }

        return region.phoneNumberCode + text
    }

    func validatePassword() throws -> String {
        guard let text = text else {
            throw CustomAuthModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Phone.Errors.empty
            )
        }

        return text
    }
}
