import Foundation

enum PhoneAuthItemType {
    case phone
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

enum PhoneAuthItemStyle {
    case editable
}

enum PhoneAuthItemState {
    case normal
    case error(String)
}

struct PhoneAuthModelItem {
    let identifier: String
    let type: PhoneAuthItemType
    let style: PhoneAuthItemStyle
    let state: PhoneAuthItemState
    var text: String?

    var isEditable: Bool {
        switch style {
        case .editable:
            return true
        }
    }
}
