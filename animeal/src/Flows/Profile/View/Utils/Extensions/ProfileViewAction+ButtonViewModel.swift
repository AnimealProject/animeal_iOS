// System
import UIKit

// SDK
import UIComponents
import Style

extension ProfileViewAction {
    var buttonView: ButtonView {
        let buttonsFactory = ButtonViewFactory()
        let model = ButtonView.Model(
            identifier: identifier,
            viewType: ButtonView.self,
            title: title
        )

        if isEnabled {
            switch style {
            case .primary:
                let buttonView = buttonsFactory.makeAccentButton()
                buttonView.configure(model)
                return buttonView
            case .secondary:
                let buttonView = buttonsFactory.makeAccentInvertedButton()
                buttonView.configure(model)
                return buttonView
            }
        } else {
            let buttonView = buttonsFactory.makeDisabledButton()
            buttonView.configure(model)
            return buttonView
        }
    }
}
