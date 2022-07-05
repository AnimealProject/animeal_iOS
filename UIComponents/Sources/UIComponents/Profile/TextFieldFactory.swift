import UIKit

public protocol TextFieldGenerating {
    func makeTextField(for kind: TextFieldKind) -> UITextField
    func makeDefaultTextField() -> UITextField
    func makeNameTextField() -> UITextField
    func makeEmailTextField() -> UITextField
    func makePhoneTextField() -> UITextField
}

public enum TextFieldKind {
    case name
    case phone
    case email
}

public struct TextFieldFactory: StyleEngineContainable, TextFieldGenerating {
    public init() {}

    public func makeTextField(for kind: TextFieldKind) -> UITextField {
        switch kind {
        case .name:
            return makeNameTextField()
        case .email:
            return makeEmailTextField()
        case .phone:
            return makePhoneTextField()
        }
    }

    public func makeDefaultTextField() -> UITextField {
        let textField = UITextField()
        textField.font = designEngine.fonts.primary.medium(16.0).uiFont
        textField.textColor = designEngine.colors.textSecondary.uiColor
        textField.backgroundColor = designEngine.colors.secondary.uiColor
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no

        return textField
    }

    public func makeNameTextField() -> UITextField {
        let textField = makeDefaultTextField()
        textField.keyboardType = .namePhonePad
        textField.autocapitalizationType = .words

        return textField
    }

    public func makeEmailTextField() -> UITextField {
        let textField = makeDefaultTextField()
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none

        return textField
    }

    public func makePhoneTextField() -> UITextField {
        let textField = makeDefaultTextField()
        textField.keyboardType = .phonePad
        textField.autocapitalizationType = .none

        return textField
    }
}
