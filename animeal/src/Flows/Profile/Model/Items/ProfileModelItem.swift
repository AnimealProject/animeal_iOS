import Foundation
import Common
import Services

enum ProfileItemType: Hashable {
    case name
    case surname
    case email
    case phone(Region)
    case birthday

    var title: String {
        switch self {
        case .name:
            return L10n.Profile.name
        case .surname:
            return L10n.Profile.surname
        case .email:
            return L10n.Profile.email
        case .phone:
            return L10n.Profile.phoneNumber
        case .birthday:
            return L10n.Profile.birthDate
        }
    }
}

enum ProfileItemStyle: Hashable {
    case editable
    case readonly
}

enum ProfileItemState: Hashable {
    case normal
    case error(String)
}

protocol ProfileModelValidatable {
    func validate() throws -> String
}

struct ProfileModelItem: Hashable, ProfileModelValidatable {
    let identifier: String
    let type: ProfileItemType
    var style: ProfileItemStyle
    var state: ProfileItemState
    var text: String?

    @discardableResult
    func validate() throws -> String {
        switch type {
        case .name, .surname, .birthday:
            return try validateForEmptiness()
        case .email:
            return try validateEmail()
        case .phone(let region):
            return try validatePhone(region)
        }
    }
}

extension ProfileModelItem {
    var isEditable: Bool {
        switch style {
        case .editable:
            return true
        case .readonly:
            return false
        }
    }

    func validateForEmptiness() throws -> String {
        guard let text = text else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        return text
    }

    func validateEmail() throws -> String {
        let text = try validateForEmptiness()

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        guard emailPredicate.evaluate(with: text) else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.incorrectFormat
            )
        }

        return text
    }

    func validatePhone(_ region: Region) throws -> String {
        let text = try validateForEmptiness()

        guard text.count == region.phoneNumberDigitsCount else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        return region.phoneNumberCode + text
    }
}
