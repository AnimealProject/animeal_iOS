// System
import UIKit

// SDK
import UIComponents

extension PhoneAuthViewItem {
    var phoneModel: PhoneInputView.Model {
        switch state {
        case .normal:
            return PhoneInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.normal,
                content: PhoneTextContentView.Model(
                    icon: UIImage(named: "flag_georgia"),
                    prefix: "+995",
                    placeholder: placeholder,
                    text: text
                )
            )
        case .error(let error):
            return PhoneInputView.Model(
                identifier: identifier,
                title: title,
                state: TextInputView.State.error(error),
                content: PhoneTextContentView.Model(
                    icon: UIImage(named: "flag_georgia"),
                    prefix: "+995",
                    placeholder: placeholder,
                    text: text
                )
            )
        }
    }

    var passwordModel: DefaultInputView.Model {
        DefaultInputView.Model(
            identifier: identifier,
            title: title,
            state: TextInputView.State.normal,
            content: DefaultTextContentView.Model(
                placeholder: placeholder,
                text: text,
                isSecure: true
            )
        )
    }
}
