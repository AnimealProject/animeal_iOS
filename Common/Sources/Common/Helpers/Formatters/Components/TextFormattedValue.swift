import Foundation

public struct TextFormattedValue: Equatable {
    public let formattedText: String
    public let caretBeginOffset: Int

    public init(formattedText: String, caretBeginOffset: Int) {
        self.formattedText = formattedText
        self.caretBeginOffset = caretBeginOffset
    }

    public static var zero: TextFormattedValue {
        return TextFormattedValue(formattedText: "", caretBeginOffset: 0)
    }
}
