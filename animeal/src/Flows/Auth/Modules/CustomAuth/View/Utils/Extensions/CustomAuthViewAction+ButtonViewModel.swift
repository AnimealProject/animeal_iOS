// System
import UIKit

// SDK
import UIComponents
import Style

extension CustomAuthViewAction {
    var buttonView: ButtonView {
        let buttonsFactory = ButtonViewFactory()
        let model = ButtonView.Model(
            identifier: identifier,
            viewType: ButtonView.self,
            title: title
        )

        if isEnabled {
            let buttonView = buttonsFactory.makeAccentButton()
            buttonView.configure(model)
            return buttonView
        } else {
            let buttonView = buttonsFactory.makeDisabledButton()
            buttonView.configure(model)
            return buttonView
        }
    }
}
