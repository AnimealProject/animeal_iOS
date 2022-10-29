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
    var type: ProfileItemType
    var style: ProfileItemStyle
    var state: ProfileItemState
    var text: String? {
        get { _value }
        set {
            _value = transform(newValue)
        }
    }
    private var _value: String?

    init(
        identifier: String,
        type: ProfileItemType,
        style: ProfileItemStyle,
        state: ProfileItemState,
        text: String? = nil
    ) {
        self.identifier = identifier
        self.type = type
        self.style = style
        self.state = state
        self.text = text
    }

    @discardableResult
    func validate() throws -> String {
        switch type {
        case .name, .surname:
            return try validateForEmptiness()
        case .email:
            return try validateEmail()
        case .phone(let region):
            return try validatePhone(region)
        case .birthday:
            return try validateDate()
        }
    }

    func transform(_ text: String?) -> String? {
        switch type {
        case .name, .surname, .email:
            return text
        case .phone(let region):
            return trasformPhone(text, region: region)
        case .birthday:
            return transformDate(text)
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

        guard region.phoneNumberDigitsCount.contains(text.count) else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        return region.phoneNumberCode + text
    }

    func validateDate() throws -> String {
        let text = try validateForEmptiness()

        guard let date = DateFormatter.input.date(from: text) else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        return DateFormatter.output.string(from: date)
    }

    func transformDate(_ text: String?) -> String? {
        guard let text else { return nil }

        guard let outputDate = DateFormatter.output.date(from: text) else {
            return text
        }
        let dateInInputFormat = DateFormatter.input.string(from: outputDate)
        return dateInInputFormat
    }

    func trasformPhone(_ text: String?, region: Region) -> String? {
        guard let text else { return nil }

        guard text.hasPrefix(region.phoneNumberCode) else { return text }
        return String(text.dropFirst(region.phoneNumberCode.count))
    }
}

private extension DateFormatter {
    static let input: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "dd MMM, yyyy"
        return item
    }()

    static let output: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "dd/MM/yyyy"
        return item
    }()
}
