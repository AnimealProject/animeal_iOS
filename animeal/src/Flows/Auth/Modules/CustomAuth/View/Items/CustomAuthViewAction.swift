import Foundation

struct CustomAuthViewAction {
    let identifier: String
    let title: String
    var isEnabled: Bool
}

extension CustomAuthViewAction {
    static func next(isEnabled: Bool = false) -> CustomAuthViewAction {
        CustomAuthViewAction(identifier: UUID().uuidString, title: L10n.Verification.Alert.next, isEnabled: isEnabled)
    }
}
