// System
import UIKit

// SDK
import UIComponents

extension CustomAuthViewItem {
    var phoneModel: PhoneInputView.Model {
        switch state {
        case .normal:
            return PhoneInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.normal,
                content: content
            )
        case .error(let error):
            return PhoneInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.error(error),
                content: content
            )
        }
    }

    var model: DefaultInputView.Model {
        switch state {
        case .normal:
            return DefaultInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.normal,
                content: content
            )
        case .error(let error):
            return DefaultInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.error(error),
                content: content
            )
        }
    }
}
