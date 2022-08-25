import UIKit

public protocol TextFieldContentViewChangesHandable: AnyObject {
    var shouldBeginEditing: ((TextFieldContainable) -> Bool)? { get set }
    var didBeginEditing: ((TextFieldContainable) -> Void)? { get set }
    var shouldEndEditing: ((TextFieldContainable) -> Bool)? { get set }
    var didEndEditing: ((TextFieldContainable) -> Void)? { get set }
    var shouldChangeCharacters: ((TextFieldContainable, NSRange, String) -> Bool)? { get set }
    var didChange: ((TextFieldContainable) -> Void)? { get set }
    var shouldClear: ((TextFieldContainable) -> Bool)? { get set }
    var shouldReturn: ((TextFieldContainable) -> Bool)? { get set }
}

public protocol TextFieldContainable: UIView, TextFieldContentViewChangesHandable {
    var text: String? { get set }
    var placeholder: String? { get set }
    var attributedText: NSAttributedString? { get set }
    var selectedTextRange: UITextRange? { get set }
    var beginningOfDocument: UITextPosition { get }
    var keyboardAppearance: UIKeyboardAppearance { get set }
    var autocorrectionType: UITextAutocorrectionType { get set }
    var keyboardType: UIKeyboardType { get set }
    var returnKeyType: UIReturnKeyType { get set }
    var autocapitalizationType: UITextAutocapitalizationType { get set }
    var spellCheckingType: UITextSpellCheckingType { get set }
    var isSecureTextEntry: Bool { get set }

    var textColor: UIColor? { get set }
    var font: UIFont? { get set }

    var inputView: UIView? { get set }

    func position(from: UITextPosition, offset: Int) -> UITextPosition?
    func setCursorLocation(_ location: Int)
}

public final class TextFieldSingleLineView: UITextField, TextFieldContainable, UITextFieldDelegate {
    // MARK: - Properties
    public var shouldBeginEditing: ((TextFieldContainable) -> Bool)?
    public var didBeginEditing: ((TextFieldContainable) -> Void)?
    public var shouldEndEditing: ((TextFieldContainable) -> Bool)?
    public var didEndEditing: ((TextFieldContainable) -> Void)?
    public var shouldChangeCharacters: ((TextFieldContainable, NSRange, String) -> Bool)?
    public var didChange: ((TextFieldContainable) -> Void)?
    public var shouldClear: ((TextFieldContainable) -> Bool)?
    public var shouldReturn: ((TextFieldContainable) -> Bool)?

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handling
    @objc func textFieldDidChange(_ textField: UITextField) {
        didChange?(self)
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        shouldBeginEditing?(self) ?? true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditing?(self)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        shouldEndEditing?(self) ?? true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditing?(self)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        shouldChangeCharacters?(self, range, string) ?? true
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        shouldClear?(self) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shouldReturn?(self) ?? true
    }

    // MARK: - Modifications
    public func setCursorLocation(_ location: Int) {
        guard let cursorLocation = position(from: beginningOfDocument, offset: location) else { return }
        RunLoop.current.perform(inModes: [.default]) { [weak self] in
            guard let self = self else { return }
            self.selectedTextRange = self.textRange(from: cursorLocation, to: cursorLocation)
        }
    }

    // MARK: - Private methods
    private func setup() {
        delegate = self

        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

public final class TextFieldMultilineView: UITextView, TextFieldContainable, UITextViewDelegate {
    public override var text: String? {
        get { super.text }
        set {
            super.text = newValue ?? .empty
        }
    }

    public var placeholder: String?

    public override var attributedText: NSAttributedString? {
        get { super.attributedText }
        set {
            super.attributedText = newValue ?? NSAttributedString()
        }
    }

    // MARK: - Properties
    public var shouldBeginEditing: ((TextFieldContainable) -> Bool)?
    public var didBeginEditing: ((TextFieldContainable) -> Void)?
    public var shouldEndEditing: ((TextFieldContainable) -> Bool)?
    public var didEndEditing: ((TextFieldContainable) -> Void)?
    public var shouldChangeCharacters: ((TextFieldContainable, NSRange, String) -> Bool)?
    public var didChange: ((TextFieldContainable) -> Void)?
    public var shouldClear: ((TextFieldContainable) -> Bool)?
    public var shouldReturn: ((TextFieldContainable) -> Bool)?

    // MARK: - Initialization
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Handling
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        shouldBeginEditing?(self) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?(self)
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        shouldEndEditing?(self) ?? true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditing?(self)
    }

    public func textViewDidChange(_ textView: UITextView) {
        didChange?(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return shouldReturn?(self) ?? true
        }
        return shouldChangeCharacters?(self, range, text) ?? true
    }

    // MARK: - Modifications
    public func setCursorLocation(_ location: Int) {
        guard let cursorLocation = position(from: beginningOfDocument, offset: location) else { return }
        RunLoop.current.perform(inModes: [.default]) { [weak self] in
            guard let self = self else { return }
            self.selectedTextRange = self.textRange(from: cursorLocation, to: cursorLocation)
        }
    }

    // MARK: - Private methods
    private func setup() {
        delegate = self
    }
}
