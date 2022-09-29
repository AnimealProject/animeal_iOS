import Foundation

struct ProfileViewAction {
    let identifier: String
    let title: String
    let isEnabled: Bool
}

extension ProfileViewAction {
    init(modelAction: ProfileModelAction) {
        self.identifier = modelAction.identifier
        self.title = modelAction.title
        self.isEnabled = modelAction.isEnabled
    }
}
