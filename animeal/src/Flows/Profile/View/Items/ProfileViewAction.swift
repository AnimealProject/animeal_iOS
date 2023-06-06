import Foundation

struct ProfileViewAction {
    let identifier: String
    let title: String
    let isEnabled: Bool
    let style: ProfileActionStyle
}

extension ProfileViewAction {
    init(modelAction: ProfileModelAction) {
        let appearance = modelAction.appearance
        self.identifier = appearance.identifier
        self.title = appearance.title
        self.isEnabled = appearance.isEnabled
        self.style = appearance.style
    }
}
