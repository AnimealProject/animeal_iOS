// System
import UIKit

// SDK
import UIComponents

extension PhoneAuthViewItem {
    var phoneModel: PhoneTextFieldView.Model {
        switch state {
        case .normal:
            return PhoneTextFieldView.Model(
                identifier: identifier,
                title: title,
                icon: UIImage(named: "flag_georgia"),
                prefix: "+995",
                placeholder: placeholder,
                text: text,
                state: TextFieldState.normal
            )
        case .error(let error):
            return PhoneTextFieldView.Model(
                identifier: identifier,
                title: title,
                icon: UIImage(named: "flag_georgia"),
                prefix: "+995",
                placeholder: placeholder,
                text: text,
                state: TextFieldState.error(error)
            )
        }
    }

    var passwordModel: TextFieldView.Model {
        TextFieldView.Model(
            identifier: identifier,
            description: title,
            placeholderText: placeholder,
            textInputKind: .password
        )
    }
}
