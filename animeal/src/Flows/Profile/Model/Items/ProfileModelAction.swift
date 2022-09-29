import Foundation

enum ProfileModelRequestAction {
    case complete
    case changeSource(([ProfileModelItem]) -> [ProfileModelItem])
    case changeActions(([ProfileModelAction]) -> [ProfileModelAction])
}

struct ProfileModelAction {
    let identifier: String
    let title: String
    let isEnabled: Bool
    let action: ((String) -> [ProfileModelRequestAction])?
}
