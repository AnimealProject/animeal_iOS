import UIKit

public protocol TextFieldGenerating {
    func makeDefaultTextField() -> TextFieldContainable
    func makeNameTextField() -> TextFieldContainable
    func makeEmailTextField() -> TextFieldContainable
    func makePhoneTextField() -> TextFieldContainable
}

public struct TextFieldViewFactory: StyleEngineContainable, TextFieldGenerating {
    public init() {}

    public func makeDefaultTextField() -> TextFieldContainable {
        let textField = TextFieldSingleLineView()
        textField.font = designEngine.fonts.primary.medium(16.0)
        textField.textColor = designEngine.colors.textPrimary
        textField.tintColor = designEngine.colors.accent
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        return textField
    }

    public func makeNameTextField() -> TextFieldContainable {
        let textField = makeDefaultTextField()
        textField.keyboardType = .namePhonePad
        textField.autocapitalizationType = .words

        return textField
    }

    public func makeEmailTextField() -> TextFieldContainable {
        let textField = makeDefaultTextField()
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none

        return textField
    }

    public func makePhoneTextField() -> TextFieldContainable {
        let textField = makeDefaultTextField()
        textField.returnKeyType = .done
        textField.keyboardType = .phonePad
        textField.autocapitalizationType = .none

        return textField
    }

    public func makePasswordTextField() -> TextFieldContainable {
        let textField = makeDefaultTextField()
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none

        return textField
    }
}
