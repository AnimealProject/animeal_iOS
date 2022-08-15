import Foundation

struct PhoneAuthViewItem {
    let identifier: String
    let type: PhoneAuthItemType
    let state: PhoneAuthItemState
    let isEditable: Bool
    let title: String
    let placeholder: String
    let text: String?
}
