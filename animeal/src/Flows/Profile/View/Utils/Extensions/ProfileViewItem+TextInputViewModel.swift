// System
import UIKit

// SDK
import UIComponents

extension ProfileViewItem {
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

    var dateModel: DateInputView.Model {
        switch state {
        case .normal:
            return DateInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.normal,
                content: content
            )
        case .error(let error):
            return DateInputView.Model(
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
