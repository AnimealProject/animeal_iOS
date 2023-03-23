import Foundation

open class DefaultTextInputFormatter: TextInputFormatter, TextFormatter, TextUnformatter {
    // MARK: - Dependencies
    private let caretPositionCorrector: DefaultCaretPositionCorrector
    private let textFormatter: DefaultTextFormatter
    private let rangeCalculator: DefaultRangeCalculator

    // MARK: - Properties
    private var textPattern: String { textFormatter.textPattern }
    private var patternSymbol: Character { textFormatter.patternSymbol }

    // MARK: - Initialization
    public init(
        textPattern: String,
        patternSymbol: Character = "x"
    ) {
        self.caretPositionCorrector = DefaultCaretPositionCorrector(
            textPattern: textPattern,
            patternSymbol: patternSymbol
        )
        self.textFormatter = DefaultTextFormatter(
            textPattern: textPattern,
            patternSymbol: patternSymbol
        )
        self.rangeCalculator = DefaultRangeCalculator()
    }

    // MARK: - TextInputFormatter
    open func formatInput(
        currentText: String,
        range: NSRange,
        replacementString text: String
    ) -> TextFormattedValue {
        guard let swiftRange = Range(range, in: currentText) else { return .zero }

        let oldUnformattedText = textFormatter.unformat(currentText) ?? ""

        let unformattedCurrentTextRange = rangeCalculator.unformattedRange(
            currentText: currentText,
            textPattern: textPattern,
            from: swiftRange,
            patternSymbol: patternSymbol
        )
        let unformattedRange = oldUnformattedText.getSameRange(
            asIn: currentText,
            sourceRange: unformattedCurrentTextRange
        )

        let newText = oldUnformattedText.replacingCharacters(
            in: unformattedRange,
            with: text
        )

        let formattedText = textFormatter.format(newText) ?? ""
        let formattedTextRange = formattedText.getSameRange(
            asIn: currentText,
            sourceRange: swiftRange
        )

        let caretOffset = getCorrectedCaretPosition(
            newText: formattedText,
            range: formattedTextRange,
            replacementString: text
        )

        return TextFormattedValue(
            formattedText: formattedText,
            caretBeginOffset: caretOffset
        )
    }

    // MARK: - TextFormatter
    open func format(_ unformattedText: String?) -> String? {
        return textFormatter.format(unformattedText)
    }

    // MARK: - TextUnformatter
    open func unformat(_ formatted: String?) -> String? {
        return textFormatter.unformat(formatted)
    }
}

// MARK: - Private
private extension DefaultTextInputFormatter {
    // MARK: - Caret position calculation
    func getCorrectedCaretPosition(
        newText: String,
        range: Range<String.Index>,
        replacementString: String
    ) -> Int {
        return caretPositionCorrector.calculateCaretPositionOffset(
            newText: newText,
            originalRange: range,
            replacementText: replacementString
        )
    }
}
