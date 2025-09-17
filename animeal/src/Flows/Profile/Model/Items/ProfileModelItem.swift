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
    var selected: Bool {
        get {
            style == .readonly ? true : _selected ?? false
        }
        set {
            _selected = style == .readonly ? true : newValue
        }
    }
    var date: Date? { transformDate(text) }
    private var _value: String?
    private var _selected: Bool?

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
            let text = try validateForEmptiness()
            try validateCharacterLength(text)
            try validateCharacterFormat(text)
            return text
        case .email:
            return try validateEmail()
        case .phone(let region):
            return try validatePhone(region)
        case .birthday:
            return try validateCheckBox()
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

// MARK: - Constants
extension ProfileModelItem {
    enum Constants {
        static let minimumUserAge = 15
        static let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
}

// MARK: - Validation
extension ProfileModelItem {
    func validateForEmptiness() throws -> String {
        guard let text = text else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        return text
    }

    func validateCharacterLength(_ text: String) throws {
        guard text.count >= 2 && text.count <= 35 else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.incorrectCharactersLength
            )
        }
    }

    func validateCharacterFormat(_ text: String) throws {
        let letters = CharacterSet.letters
        if text.rangeOfCharacter(from: letters.inverted) != nil {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.incorrectCharacters
            )
        }
    }

    func validateEmail() throws -> String {
        let text = try validateForEmptiness()

        let emailPredicate = NSPredicate(
            format: "SELF MATCHES %@",
            Constants.emailRegEx
        )

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

    func validateCheckBox() throws -> String {
        guard selected == true else {
            throw ProfileModelItemAgeError(selected: false)
        }
        return ""
    }

    func validateDate() throws -> String {
        let text = try validateForEmptiness()

        guard let date = DateFormatter.input.date(from: text) else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.empty
            )
        }

        // Person must be more than 15 years old
        // to be able to register
        let now = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        guard let age = ageComponents.year, age >= Constants.minimumUserAge else {
            throw ProfileModelItemError(
                itemIdentifier: identifier,
                errorDescription: L10n.Profile.Errors.ageLimit(Constants.minimumUserAge)
            )
        }

        return DateFormatter.output.string(from: date)
    }
}

// MARK: - Transformation
extension ProfileModelItem {
    var isEditable: Bool {
        switch style {
        case .editable:
            return true
        case .readonly:
            return false
        }
    }

    func transformDate(_ text: String?) -> String? {
        guard let text else { return nil }

        guard let outputDate = DateFormatter.output.date(from: text) else {
            return text
        }
        let dateInInputFormat = DateFormatter.input.string(from: outputDate)
        return dateInInputFormat
    }

    func transformDate(_ text: String?) -> Date? {
        guard let text: String = transformDate(text) else { return nil }

        let date = DateFormatter.input.date(from: text)
        return date
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

extension Array where Element == ProfileModelItem {
    static var editable: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var editableExceptEmail: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var editableExceptPhone: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .editable, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.default), style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .editable, state: .normal)
        ]
    }

    static var readonly: [ProfileModelItem] {
        [
            ProfileModelItem(identifier: UUID().uuidString, type: .name, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .surname, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .email, style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .phone(.GE), style: .readonly, state: .normal),
            ProfileModelItem(identifier: UUID().uuidString, type: .birthday, style: .readonly, state: .normal)
        ]
    }

    func toReadonly(
        except: @escaping (ProfileModelItem) -> Bool = { _ in false }
    ) -> [ProfileModelItem] {
        map { item in
            guard !except(item) else { return item }
            var item = item
            item.style = .readonly
            return item
        }
    }

    func toEditable(
        except: @escaping (ProfileModelItem) -> Bool = { _ in false }
    ) -> [ProfileModelItem] {
        map { item in
            guard !except(item) else { return item }
            var item = item
            item.style = .editable
            return item
        }
    }
}

extension ProfileItemType {
    var userAttributeKey: UserProfileAttributeKey {
        switch self {
        case .name:
            return .name
        case .surname:
            return .familyName
        case .email:
            return .email
        case .phone:
            return .phoneNumber
        case .birthday:
            return .birthDate
        }
    }

    init?(userAttributeKey: UserProfileAttributeKey) {
        switch userAttributeKey {
        case .name:
            self = .name
        case .familyName:
            self = .surname
        case .email:
            self = .email
        case .phoneNumber:
            self = .phone(.GE)
        case .birthDate:
            self = .birthday
        default:
            return nil
        }
    }
}
